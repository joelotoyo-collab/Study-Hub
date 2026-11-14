// Fish Audio text-to-speech edge function.
// Keeps the Fish Audio API key server-side (FISH_AUDIO_API_KEY env var).
// Accepts { text, voice?, speed? } and returns audio/mpeg bytes.
// Caches generated audio in the `audio_cache` table keyed by a hash of
// (text + voice + speed) so repeated reads of the same note do not re-generate.

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

const DEFAULT_VOICE = "default";

async function sha256(text: string): Promise<string> {
  const data = new TextEncoder().encode(text);
  const hash = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(hash))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 200, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  try {
    const apiKey = Deno.env.get("FISH_AUDIO_API_KEY");
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: "Text-to-speech is not configured. An administrator needs to add the Fish Audio API key." }),
        { status: 503, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const body = await req.json();
    const text: string | undefined = body?.text;
    const voice: string = body?.voice || DEFAULT_VOICE;
    const speed: number = typeof body?.speed === "number" ? body.speed : 1.0;
    const format: string = body?.format || "mp3";

    if (!text || typeof text !== "string" || text.trim().length === 0) {
      return new Response(JSON.stringify({ error: "Text is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (text.length > 5000) {
      return new Response(
        JSON.stringify({ error: "Text is too long for a single request (maximum 5000 characters). Please read in shorter sections." }),
        { status: 413,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const cacheKey = await sha256(`${text}|${voice}|${speed}|${format}`);

    // Supabase client for cache lookup/storage.
    const supabaseUrl = Deno.env.get("SUPABASE_URL") as string;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") as string;

    // Try cache first (if service role key is available)
    if (supabaseUrl && serviceRoleKey) {
      try {
        const cacheResp = await fetch(
          `${supabaseUrl}/rest/v1/audio_cache?select=audio_data&id=eq.${cacheKey}&limit=1`,
          {
            headers: {
              apikey: serviceRoleKey,
              Authorization: `Bearer ${serviceRoleKey}`,
            },
          },
        );
        if (cacheResp.ok) {
          const rows = await cacheResp.json();
          if (Array.isArray(rows) && rows.length > 0 && rows[0]?.audio_data) {
            const base64 = rows[0].audio_data as string;
            const binary = atob(base64);
            const bytes = new Uint8Array(binary.length);
            for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
            return new Response(bytes, {
              headers: {
                ...corsHeaders,
                "Content-Type": "audio/mpeg",
                "X-Audio-Cache": "HIT",
              },
            });
          }
        }
      } catch (_cacheErr) {
        // Cache lookup failed; continue to generate fresh audio.
      }
    }

    // Build Fish Audio TTS request.
    // Fish Audio API: POST https://api.fish.audio/v1/tts
    // Body: { text, reference_id (voice), format? }
    // The voice maps to a Fish Audio model/reference id. We allow a small
    // allowlist of voice keys the frontend can choose from.
    const voiceMap: Record<string, string> = {
      default: "b69b6e4d-d714-405a-92f1-2a3f4f4f4f4f",
    };
    const referenceId = voiceMap[voice] || voiceMap.default;

    const fishResp = await fetch("https://api.fish.audio/v1/tts", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        text,
        reference_id: referenceId,
        format,
        speed,
        chunk_length: 120,
      }),
    });

    if (!fishResp.ok) {
      const errText = await fishResp.text();
      return new Response(
        JSON.stringify({
          error: `Fish Audio request failed (${fishResp.status}).`,
          detail: errText.slice(0, 300),
        }),
        {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const audioBuffer = await fishResp.arrayBuffer();
    const audioBytes = new Uint8Array(audioBuffer);

    // Store in cache for reuse.
    if (supabaseUrl && serviceRoleKey) {
      try {
        let binary = "";
        const chunkSize = 0x8000;
        for (let i = 0; i < audioBytes.length; i += chunkSize) {
          binary += String.fromCharCode(...audioBytes.subarray(i, i + chunkSize));
        }
        const base64 = btoa(binary);

        await fetch(`${supabaseUrl}/rest/v1/audio_cache`, {
          method: "POST",
          headers: {
            apikey: serviceRoleKey,
            Authorization: `Bearer ${serviceRoleKey}`,
            "Content-Type": "application/json",
            Prefer: "return=minimal",
          },
          body: JSON.stringify({
            id: cacheKey,
            audio_data: base64,
            voice,
            speed,
            text_preview: text.slice(0, 200),
            created_at: new Date().toISOString(),
          }),
        });
      } catch (_storeErr) {
        // Cache store failed; audio still returned to client.
      }
    }

    return new Response(audioBytes, {
      headers: {
        ...corsHeaders,
        "Content-Type": "audio/mpeg",
        "X-Audio-Cache": "MISS",
      },
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : "Unknown error";
    return new Response(
      JSON.stringify({ error: "Text-to-speech failed", detail: message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
