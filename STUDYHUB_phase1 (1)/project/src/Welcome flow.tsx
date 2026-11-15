
import { useEffect, useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import {
  GraduationCap, BookOpen, Sparkles, Eye, EyeOff,
  ArrowRight, CheckCircle2
} from 'lucide-react';

type Props = {
  children: React.ReactNode;
};

export default function WelcomeFlow({ children }: Props) {
  const [loading, setLoading] = useState(true);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [studentClass, setStudentClass] = useState('SS1');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [accepted, setAccepted] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);

  useEffect(() => {
    const timer = window.setTimeout(() => setLoading(false), 2500);
    return () => window.clearTimeout(timer);
  }, []);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError('');
    setSuccess(false);

    if (name.trim().length < 2) {
      setError('Please enter your full name.');
      return;
    }

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      setError('Please enter a valid email address.');
      return;
    }

    if (password.length < 8) {
      setError('Your password must contain at least 8 characters.');
      return;
    }

    if (password !== confirmPassword) {
      setError('Your passwords do not match.');
      return;
    }

    if (!accepted) {
      setError('Please accept the terms to continue.');
      return;
    }

    setSuccess(true);
  }

  const inputClass =
    'w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-800 outline-none transition focus:border-blue-500 focus:ring-4 focus:ring-blue-100';

  return (
    <AnimatePresence mode="wait">
      {loading ? (
        <motion.div
          key="splash"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 z-[100] flex flex-col items-center justify-center overflow-hidden bg-[#102b62] px-6 text-white"
        >
          <motion.div
            animate={{ scale: [1, 1.08, 1], rotate: [0, 5, 0] }}
            transition={{ duration: 2, repeat: Infinity }}
            className="mb-7 flex h-24 w-24 items-center justify-center rounded-[28px] bg-white shadow-2xl"
          >
            <GraduationCap size={55} className="text-blue-700" />
          </motion.div>

          <motion.h1
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="text-4xl font-black tracking-tight"
          >
            STUDY<span className="text-cyan-300">HUB</span>
          </motion.h1>

          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.7 }}
            className="mt-3 text-sm font-medium tracking-[0.25em] text-blue-100"
          >
            LEARN. PRACTISE. EXCEL.
          </motion.p>

          <div className="mt-12 h-1.5 w-40 overflow-hidden rounded-full bg-white/20">
            <motion.div
              initial={{ width: '0%' }}
              animate={{ width: '100%' }}
              transition={{ duration: 2.2 }}
              className="h-full rounded-full bg-cyan-300"
            />
          </div>

          <p className="mt-4 text-xs text-blue-200">
            Preparing your learning space...
          </p>

          <Sparkles className="absolute right-12 top-24 text-cyan-300/40" size={30} />
          <BookOpen className="absolute bottom-24 left-10 text-white/20" size={45} />
        </motion.div>
      ) : (
        <motion.div
          key="signup"
          initial={{ opacity: 0, y: 15 }}
          animate={{ opacity: 1, y: 0 }}
          className="flex min-h-screen items-center justify-center bg-[#f4f7fc] px-4 py-10"
        >
          <div className="grid w-full max-w-5xl overflow-hidden rounded-3xl bg-white shadow-xl md:grid-cols-2">

            <div className="hidden flex-col justify-between bg-gradient-to-br from-[#102b62] to-blue-700 p-10 text-white md:flex">
              <div>
                <div className="flex items-center gap-3">
                  <GraduationCap size={35} />
                  <span className="text-2xl font-black">
                    STUDYHUB
                  </span>
                </div>

                <div className="mt-24">
                  <h2 className="text-4xl font-extrabold leading-tight">
                    Your journey to academic excellence starts here.
                  </h2>
                  <p className="mt-5 text-sm leading-7 text-blue-100">
                    Discover a smarter way to learn, practise and prepare
                    for your examinations.
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-3 text-sm text-blue-100">
                <CheckCircle2 size={19} />
                Your personal learning space
              </div>
            </div>

            <div className="p-6 sm:p-10">
              <div className="mb-7 text-center md:text-left">
                <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-50 text-blue-700 md:mx-0">
                  <GraduationCap size={27} />
                </div>

                <h2 className="text-2xl font-extrabold text-slate-900">
                  Create your account
                </h2>

                <p className="mt-2 text-sm text-slate-500">
                  Join STUDYHUB and start learning smarter.
                </p>
              </div>

              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="mb-1.5 block text-sm font-semibold text-slate-700">
                    Full name
                  </label>
                  <input
                    value={name}
                    onChange={e => setName(e.target.value)}
                    placeholder="Enter your full name"
                    className={inputClass}
                    autoComplete="name"
                    required
                  />
                </div>

                <div>
                  <label className="mb-1.5 block text-sm font-semibold text-slate-700">
                    Email address
                  </label>
                  <input
                    type="email"
                    value={email}
                    onChange={e => setEmail(e.target.value)}
                    placeholder="you@example.com"
                    className={inputClass}
                    autoComplete="email"
                    required
                  />
                </div>

                <div>
                  <label className="mb-1.5 block text-sm font-semibold text-slate-700">
                    Current class
                  </label>
                  <select
                    value={studentClass}
                    onChange={e => setStudentClass(e.target.value)}
                    className={inputClass}
                  >
                    <option value="SS1">SS1</option>
                    <option value="SS2">SS2</option>
                    <option value="SS3">SS3</option>
                  </select>
                </div>

                <div>
                  <label className="mb-1.5 block text-sm font-semibold text-slate-700">
                    Password
                  </label>
                  <div className="relative">
                    <input
                      type={showPassword ? 'text' : 'password'}
                      value={password}
                      onChange={e => setPassword(e.target.value)}
                      placeholder="At least 8 characters"
                      className={`${inputClass} pr-12`}
                      autoComplete="new-password"
                      required
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400"
                      aria-label="Toggle password visibility"
                    >
                      {showPassword ? <EyeOff size={19} /> : <Eye size={19} />}
                    </button>
                  </div>
                </div>

                <div>
                  <label className="mb-1.5 block text-sm font-semibold text-slate-700">
                    Confirm password
                  </label>
                  <div className="relative">
                    <input
                      type={showConfirm ? 'text' : 'password'}
                      value={confirmPassword}
                      onChange={e => setConfirmPassword(e.target.value)}
                      placeholder="Enter your password again"
                      className={`${inputClass} pr-12`}
                      autoComplete="new-password"
                      required
                    />
                    <button
                      type="button"
                      onClick={() => setShowConfirm(!showConfirm)}
                      className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400"
                      aria-label="Toggle confirm password visibility"
                    >
                      {showConfirm ? <EyeOff size={19} /> : <Eye size={19} />}
                    </button>
                  </div>
                </div>

                <label className="flex items-start gap-2 text-xs leading-5 text-slate-500">
                  <input
                    type="checkbox"
                    checked={accepted}
                    onChange={e => setAccepted(e.target.checked)}
                    className="mt-1 accent-blue-700"
                  />
                  I agree to the STUDYHUB terms and privacy policy.
                </label>

                {error && (
                  <p className="rounded-lg bg-red-50 p-3 text-xs text-red-600">
                    {error}
                  </p>
                )}

                {success && (
                  <p className="rounded-lg bg-emerald-50 p-3 text-xs text-emerald-700">
                    Your details have passed validation! Account creation will
                    be activated when we connect Supabase.
                  </p>
                )}

                <button
                  type="submit"
                  className="flex w-full items-center justify-center gap-2 rounded-xl bg-blue-700 py-3.5 text-sm font-bold text-white shadow-lg shadow-blue-100 transition hover:bg-blue-800"
                >
                  Create account <ArrowRight size={17} />
                </button>
              </form>

              <p className="mt-6 text-center text-xs text-slate-400">
                © 2026 STUDYHUB. Learn at your pace.
              </p>
            </div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
