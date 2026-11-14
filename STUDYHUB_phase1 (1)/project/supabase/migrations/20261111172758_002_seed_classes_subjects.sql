/*
# Seed: Classes, Subjects, and Class-Subject mappings

## Summary
Populates the `classes` table with SS1, SS2, SS3 and the `subjects` table with the
comprehensive list of Nigerian secondary-school subjects requested for STUDYHUB.
Links subjects to classes via `class_subjects` — all subjects are available to all
three classes for now; admins can refine this later via the CMS.

## Notes
- Subjects are referenced by slug (stable identifier) in later migrations/code.
- No user data is created.
- Idempotent: uses ON CONFLICT DO NOTHING.
*/

insert into public.classes (slug, name, level) values
  ('ss1', 'SS1', 1),
  ('ss2', 'SS2', 2),
  ('ss3', 'SS3', 3)
on conflict (slug) do nothing;

insert into public.subjects (slug, name, icon, category, description) values
  ('mathematics', 'Mathematics', 'Sigma', 'Science & Mathematics', 'Numbers, quantity, structure, space and change — the foundation of analytical thinking.'),
  ('english-language', 'English Language', 'BookOpen', 'Languages', 'Reading, writing, grammar, comprehension and oral English for effective communication.'),
  ('further-mathematics', 'Further Mathematics', 'FunctionSquare', 'Science & Mathematics', 'Advanced mathematics including calculus, matrices, vectors and complex numbers.'),
  ('biology', 'Biology', 'Leaf', 'Sciences', 'The study of living organisms — their structure, function, growth and classification.'),
  ('chemistry', 'Chemistry', 'FlaskConical', 'Sciences', 'Matter, its properties, composition and the changes it undergoes.'),
  ('physics', 'Physics', 'Atom', 'Sciences', 'Energy, matter, motion and the fundamental laws governing the physical world.'),
  ('economics', 'Economics', 'TrendingUp', 'Social Sciences', 'Production, distribution and consumption of goods and services.'),
  ('government', 'Government', 'Landmark', 'Social Sciences', 'Political institutions, processes, constitution and civic structures.'),
  ('geography', 'Geography', 'Globe', 'Social Sciences', 'The earth, its features, resources and human-environment relationships.'),
  ('civic-education', 'Civic Education', 'Scale', 'Social Sciences', 'Rights, responsibilities, values and democratic governance for citizens.'),
  ('literature-in-english', 'Literature-in-English', 'Feather', 'Languages', 'Study of prose, drama and poetry — analysis of literary works in English.'),
  ('financial-accounting', 'Financial Accounting', 'Calculator', 'Commercial', 'Recording, classifying and reporting financial transactions.'),
  ('commerce', 'Commerce', 'ShoppingCart', 'Commercial', 'Trade, business activities and the exchange of goods and services.'),
  ('agricultural-science', 'Agricultural Science', 'Wheat', 'Sciences', 'Crop and livestock production, soil management and agricultural practices.'),
  ('computer-studies', 'Computer Studies', 'Cpu', 'Technology', 'Computer hardware, software, programming fundamentals and ICT applications.'),
  ('data-processing', 'Data Processing', 'Database', 'Technology', 'Data collection, management, analysis and information systems.'),
  ('christian-religious-studies', 'Christian Religious Studies', 'Church', 'Humanities', 'Biblical studies, Christian teachings and moral lessons from scripture.'),
  ('islamic-studies', 'Islamic Studies', 'Moon', 'Humanities', 'Quranic teachings, Islamic history, beliefs and moral instruction.'),
  ('home-management', 'Home Management', 'Home', 'Vocational', 'Management of family resources, clothing, housing and home living.'),
  ('food-and-nutrition', 'Food and Nutrition', 'Utensils', 'Vocational', 'Food science, meal planning, preparation and nutritional principles.'),
  ('technical-drawing', 'Technical Drawing', 'Ruler', 'Vocational', 'Geometric construction, engineering and architectural drawing.'),
  ('visual-arts', 'Visual Arts', 'Palette', 'Vocational', 'Drawing, painting, design and the creative and visual expression of ideas.')
on conflict (slug) do nothing;

-- Map every subject to every class
insert into public.class_subjects (class_id, subject_id)
select c.id, s.id
from public.classes c
cross join public.subjects s
where not exists (
  select 1 from public.class_subjects cs
  where cs.class_id = c.id and cs.subject_id = s.id
);
