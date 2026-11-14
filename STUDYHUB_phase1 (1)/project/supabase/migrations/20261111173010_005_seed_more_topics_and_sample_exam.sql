/*
# Seed: SS1 English and Biology topics + sample practice questions

## Summary
1. Adds one SS1 English Language topic ("Comprehension Skills") with study notes
   and flashcards — original educational material.
2. Adds one SS1 Biology topic ("The Cell") with study notes, formulas, and flashcards.
3. Adds a clearly-labelled SAMPLE examination (question_source_type = 'sample')
   for WASSCE Mathematics with 5 original practice questions, options, answers
   and explanations. These are NOT labelled as official past questions.

## Content integrity
- All exam questions use question_source_type = 'sample' and the examination
  title explicitly states "Original sample questions — not official past papers."
- Admins can import verified official past questions later via the CMS.
*/

do $$
declare
  v_ss1 uuid;
  v_eng_id uuid;
  v_bio_id uuid;
  v_math_id uuid;
  v_topic_id uuid;
  v_exam_id uuid;
  v_q_id uuid;
begin
  select id into v_ss1 from public.classes where slug = 'ss1';
  select id into v_eng_id from public.subjects where slug = 'english-language';
  select id into v_bio_id from public.subjects where slug = 'biology';
  select id into v_math_id from public.subjects where slug = 'mathematics';

  -- ===== English: Comprehension Skills =====
  insert into public.topics (subject_id, class_id, title, slug, description, order_index, is_published)
  values (v_eng_id, v_ss1, 'Comprehension Skills', 'comprehension-skills',
          'Techniques for understanding, analysing and answering questions on a reading passage.',
          1, true)
  on conflict (class_id, subject_id, slug) do update set
    title = excluded.title, description = excluded.description,
    order_index = excluded.order_index, is_published = excluded.is_published
  returning id into v_topic_id;

  insert into public.study_notes (topic_id, content) values (v_topic_id,
'## Introduction

Comprehension is the ability to read a passage, understand its meaning, and answer questions based on it. It is one of the most important skills in English Language and appears in nearly every examination.

## Learning Objectives

By the end of this lesson, you will be able to:

1. Read a passage actively and identify its main idea.
2. Answer direct, inferential and evaluative questions accurately.
3. Use context clues to determine the meaning of unfamiliar words.
4. Write answers in clear, grammatically correct sentences.

## Types of Comprehension Questions

- **Direct questions:** The answer is stated openly in the passage. Find the relevant sentence and rephrase it.
- **Inferential questions:** The answer is not stated directly; you must reason from clues in the passage.
- **Evaluative questions:** You must judge, justify or give an opinion supported by evidence from the passage.

## Steps for Answering Comprehension Questions

1. **Read the passage carefully** at least twice before attempting the questions.
2. **Underline key ideas** or note them mentally as you read.
3. **Read each question** and locate the relevant part of the passage.
4. **Answer in your own words** where the question requires it, but stay faithful to the passage.
5. **Check your grammar and spelling** before finishing.

## Using Context Clues

When you meet an unfamiliar word:

- Look at the sentence before and after for clues.
- Identify whether the word is being defined, contrasted, or exemplified nearby.
- Replace the word with a guess and see if the sentence still makes sense.

## Common Mistakes to Avoid

- Copying whole sentences from the passage instead of answering in your own words.
- Answering a different question from the one asked.
- Ignoring the instruction "use your own words."
- Writing incomplete sentences as answers.

## Key Points to Remember

- Read actively: think while you read.
- Every answer must be supported by the passage.
- Use your own words unless told otherwise.
- Watch your grammar, tense and spelling.

## Topic Summary

Strong comprehension comes from active reading, locating evidence, and expressing answers clearly. Mastering direct, inferential and evaluative question types will improve your performance in English Language examinations.')
  on conflict (topic_id) do update set content = excluded.content, updated_at = now();

  insert into public.flashcards (topic_id, subject_id, class_id, front, back) values
  (v_topic_id, v_eng_id, v_ss1, 'What are the three main types of comprehension questions?', 'Direct, inferential and evaluative questions.'),
  (v_topic_id, v_eng_id, v_ss1, 'What is a direct comprehension question?', 'A question whose answer is stated openly in the passage.'),
  (v_topic_id, v_eng_id, v_ss1, 'Why should you use context clues?', 'To work out the meaning of unfamiliar words from the surrounding text.'),
  (v_topic_id, v_eng_id, v_ss1, 'Name two common mistakes in comprehension answers.', 'Copying whole sentences from the passage and answering a different question from the one asked.');


  -- ===== Biology: The Cell =====
  insert into public.topics (subject_id, class_id, title, slug, description, order_index, is_published)
  values (v_bio_id, v_ss1, 'The Cell', 'the-cell',
          'The structure and functions of the cell, the basic unit of life, and cell organelles.',
          1, true)
  on conflict (class_id, subject_id, slug) do update set
    title = excluded.title, description = excluded.description,
    order_index = excluded.order_index, is_published = excluded.is_published
  returning id into v_topic_id;

  insert into public.study_notes (topic_id, content) values (v_topic_id,
'## Introduction

The cell is the basic structural and functional unit of all living organisms. Every living thing — from the smallest bacterium to the largest tree — is made of one or more cells. Understanding the cell is the foundation of biology.

## Learning Objectives

By the end of this lesson, you will be able to:

1. Define a cell and state the cell theory.
2. Identify and describe the main organelles of a cell.
3. Distinguish between plant and animal cells.
4. Explain the functions of key cell organelles.

## The Cell Theory

The cell theory states that:

1. All living things are made of one or more cells.
2. The cell is the basic unit of life.
3. All cells arise from pre-existing cells.

## Types of Cells

- **Prokaryotic cells:** Cells without a true nucleus (e.g. bacteria). Their genetic material floats in the cytoplasm.
- **Eukaryotic cells:** Cells with a true nucleus enclosed by a nuclear membrane (e.g. plant, animal and fungal cells).

## Key Organelles and Their Functions

- **Nucleus:** Controls all cell activities and contains genetic material (DNA).
- **Cytoplasm:** The jelly-like substance where most chemical reactions take place.
- **Cell membrane:** A selectively permeable layer that controls what enters and leaves the cell.
- **Mitochondria:** The site of respiration where energy is released from food.
- **Ribosomes:** The site of protein synthesis.
- **Endoplasmic reticulum:** Transports materials within the cell.
- **Golgi body:** Packages and secretes cell products.
- **Chloroplasts (plant cells only):** Contain chlorophyll and are the site of photosynthesis.
- **Cell wall (plant cells only):** A rigid outer layer made of cellulose that gives the cell a fixed shape.
- **Large vacuole (plant cells only):** A sac filled with cell sap that stores water and nutrients.

## Differences Between Plant and Animal Cells

| Feature | Plant Cell | Animal Cell |
|---|---|---|
| Cell wall | Present (cellulose) | Absent |
| Chloroplasts | Present | Absent |
| Vacuole | Large, central | Small or absent |
| Shape | Fixed (rectangular) | Irregular |
| Nucleus | Present | Present |

## Key Points to Remember

- The cell is the basic unit of life.
- Prokaryotes lack a true nucleus; eukaryotes have one.
- Plant cells have a cell wall, chloroplasts and a large vacuole; animal cells do not.
- The mitochondrion is the powerhouse of the cell.

## Topic Summary

The cell is the fundamental unit of all living organisms. Knowing the structure and function of each organelle, and the differences between plant and animal cells, forms the basis for understanding all higher biological processes.')
  on conflict (topic_id) do update set content = excluded.content, updated_at = now();

  insert into public.formulas (topic_id, name, expression, variables, when_to_use, worked_example) values
  (v_topic_id, 'Magnification', 'Magnification = Image size ÷ Object size',
   '[{"symbol":"Image size","meaning":"the measured size of the image seen under the microscope"},{"symbol":"Object size","meaning":"the actual size of the specimen"}]',
   'Use to calculate how much larger the image appears compared to the real object.',
   'If the image is 40 mm and the object is 2 mm, magnification = 40 ÷ 2 = 20×.');

  insert into public.flashcards (topic_id, subject_id, class_id, front, back) values
  (v_topic_id, v_bio_id, v_ss1, 'What is the cell theory?', 'All living things are made of cells, the cell is the basic unit of life, and all cells come from pre-existing cells.'),
  (v_topic_id, v_bio_id, v_ss1, 'Which organelle is the powerhouse of the cell?', 'The mitochondrion — it is the site of respiration where energy is released.'),
  (v_topic_id, v_bio_id, v_ss1, 'Name two features present in plant cells but absent in animal cells.', 'Cell wall (cellulose) and chloroplasts.'),
  (v_topic_id, v_bio_id, v_ss1, 'What is the function of the nucleus?', 'It controls all cell activities and contains the genetic material (DNA).');


  -- ===== Sample WASSCE Mathematics examination =====
  insert into public.examinations (exam_type, subject_id, year, title, question_source_type, is_published)
  values ('WASSCE', v_math_id, 2023,
          'Mathematics — Original sample questions (not official past papers)',
          'sample', true)
  on conflict (exam_type, subject_id, year) do update set
    title = excluded.title, question_source_type = excluded.question_source_type,
    is_published = excluded.is_published
  returning id into v_exam_id;

  -- Q1
  insert into public.examination_questions (examination_id, question_number, question_text, has_options)
  values (v_exam_id, 1, 'Convert 101101 (base 2) to base 10.', true)
  returning id into v_q_id;
  insert into public.question_options (question_id, label, option_text, order_index) values
    (v_q_id, 'A', '43', 1), (v_q_id, 'B', '45', 2),
    (v_q_id, 'C', '47', 3), (v_q_id, 'D', '55', 4);
  insert into public.question_answers (question_id, correct_option_label, explanation)
  values (v_q_id, 'B',
    'Expand using place values: 1×2^5 + 0×2^4 + 1×2^3 + 1×2^2 + 0×2^1 + 1×2^0 = 32 + 0 + 8 + 4 + 0 + 1 = 45.');

  -- Q2
  insert into public.examination_questions (examination_id, question_number, question_text, has_options)
  values (v_exam_id, 2, 'Simplify 2^3 × 2^4.', true)
  returning id into v_q_id;
  insert into public.question_options (question_id, label, option_text, order_index) values
    (v_q_id, 'A', '2^7', 1), (v_q_id, 'B', '2^12', 2),
    (v_q_id, 'C', '4^7', 3), (v_q_id, 'D', '8^4', 4);
  insert into public.question_answers (question_id, correct_option_label, explanation)
  values (v_q_id, 'A',
    'When multiplying powers with the same base, add the indices: 2^3 × 2^4 = 2^(3+4) = 2^7 = 128.');

  -- Q3
  insert into public.examination_questions (examination_id, question_number, question_text, has_options)
  values (v_exam_id, 3, 'Evaluate log_10 1000.', true)
  returning id into v_q_id;
  insert into public.question_options (question_id, label, option_text, order_index) values
    (v_q_id, 'A', '2', 1), (v_q_id, 'B', '3', 2),
    (v_q_id, 'C', '10', 3), (v_q_id, 'D', '100', 4);
  insert into public.question_answers (question_id, correct_option_label, explanation)
  values (v_q_id, 'B',
    '10^3 = 1000, so log_10 1000 = 3.');

  -- Q4
  insert into public.examination_questions (examination_id, question_number, question_text, has_options)
  values (v_exam_id, 4, 'Express 0.000035 in standard form.', true)
  returning id into v_q_id;
  insert into public.question_options (question_id, label, option_text, order_index) values
    (v_q_id, 'A', '3.5 × 10^5', 1), (v_q_id, 'B', '3.5 × 10^(−5)', 2),
    (v_q_id, 'C', '35 × 10^(−6)', 3), (v_q_id, 'D', '0.35 × 10^(−4)', 4);
  insert into public.question_answers (question_id, correct_option_label, explanation)
  values (v_q_id, 'B',
    'Move the decimal 5 places right so 1 ≤ A < 10: 0.000035 = 3.5 × 10^(−5). The power is negative because the original number is less than 1.');

  -- Q5
  insert into public.examination_questions (examination_id, question_number, question_text, has_options)
  values (v_exam_id, 5, 'Which of the following is common to both plant and animal cells?', true)
  returning id into v_q_id;
  insert into public.question_options (question_id, label, option_text, order_index) values
    (v_q_id, 'A', 'Cell wall', 1), (v_q_id, 'B', 'Chloroplast', 2),
    (v_q_id, 'C', 'Nucleus', 3), (v_q_id, 'D', 'Large central vacuole', 4);
  insert into public.question_answers (question_id, correct_option_label, explanation)
  values (v_q_id, 'C',
    'Both plant and animal cells contain a nucleus. The cell wall, chloroplasts and a large central vacuole are found only in plant cells.');

end $$;
