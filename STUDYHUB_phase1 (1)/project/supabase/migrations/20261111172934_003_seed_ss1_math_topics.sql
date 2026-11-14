/*
# Seed: SS1 Mathematics topics with full study notes, formulas, flashcards

## Summary
Creates three verified SS1 Mathematics topics with complete study notes,
formulas, worked examples and flashcards. Original educational material
written for Nigerian secondary schools — not labelled as official past questions.

## Topics (SS1 Mathematics, curriculum order)
1. Number Bases and Conversion
2. Indices and Standard Form
3. Logarithms

Each includes study_notes, relevant formulas, and 4 flashcards.
*/

do $$
declare
  v_class_id uuid;
  v_math_id uuid;
  v_topic_id uuid;
begin
  select id into v_class_id from public.classes where slug = 'ss1';
  select id into v_math_id from public.subjects where slug = 'mathematics';

  -- ===== Topic 1: Number Bases =====
  insert into public.topics (subject_id, class_id, title, slug, description, order_index, is_published)
  values (v_math_id, v_class_id, 'Number Bases and Conversion', 'number-bases',
          'Understanding and converting between number bases including binary, octal and hexadecimal.',
          1, true)
  on conflict (class_id, subject_id, slug) do update set
    title = excluded.title, description = excluded.description,
    order_index = excluded.order_index, is_published = excluded.is_published
  returning id into v_topic_id;

  insert into public.study_notes (topic_id, content) values (v_topic_id,
'## Introduction

A number base (or radix) is the number of unique digits, including zero, that a numeral system uses to represent numbers. We are most familiar with base 10 (denary or decimal), but computers use base 2 (binary), and other bases such as base 8 (octal) and base 16 (hexadecimal) are common in computing and mathematics.

## Learning Objectives

By the end of this lesson, you will be able to:

1. Define a number base and identify the digits used in common bases.
2. Convert numbers from base 10 to other bases and vice versa.
3. Convert between binary, octal and hexadecimal.
4. Perform addition and subtraction in base 2.

## Definitions

- **Base (radix):** The number of distinct digits used in a numeral system.
- **Decimal system (base 10):** Uses digits 0 through 9.
- **Binary system (base 2):** Uses digits 0 and 1 only.
- **Octal system (base 8):** Uses digits 0 to 7.
- **Hexadecimal system (base 16):** Uses digits 0 to 9 and letters A, B, C, D, E, F (A = 10, ..., F = 15).

## Place Value in Different Bases

Just as in base 10 where place values are powers of 10 (units, tens, hundreds), the place values in base *b* are powers of *b*.

For a number written as d_n d_(n-1) ... d_1 d_0 in base *b*, its decimal value is:

> d_n × b^n + d_(n-1) × b^(n-1) + ... + d_1 × b^1 + d_0 × b^0

### Example

Convert 231 (base 4) to base 10.

> 2 × 4^2 + 3 × 4^1 + 1 × 4^0 = 2 × 16 + 3 × 4 + 1 × 1 = 32 + 12 + 1 = 45 (base 10)

## Converting from Base 10 to Other Bases

To convert a decimal number to base *b*, repeatedly divide the number by *b* and record the remainders. Read the remainders from the last to the first.

### Worked Example

Convert 45 (base 10) to base 2.

> 45 ÷ 2 = 22 remainder **1**
> 22 ÷ 2 = 11 remainder **0**
> 11 ÷ 2 = 5  remainder **1**
> 5  ÷ 2 = 2  remainder **1**
> 2  ÷ 2 = 1  remainder **0**
> 1  ÷ 2 = 0  remainder **1**

Reading remainders from bottom to top: 45 (base 10) = 101101 (base 2).

## Converting Between Binary, Octal and Hexadecimal

- **Binary to octal:** Group the binary digits in sets of three from the right, then convert each group.
- **Binary to hexadecimal:** Group in sets of four from the right, then convert each group.

### Example

Convert 101101 (base 2) to octal.

> Group as 101 101 then convert each group to 5 5, giving 55 (base 8).

## Addition in Base 2

Add binary numbers column by column, remembering:

> 0 + 0 = 0, 0 + 1 = 1, 1 + 0 = 1, 1 + 1 = 10 (write 0, carry 1)

### Worked Example

Add 1011 (base 2) and 1101 (base 2).

> Starting from the right: 1+1 = 10 (write 0, carry 1); 1+0+1 = 10 (write 0, carry 1); 0+1+1 = 10 (write 0, carry 1); 1+1+1 = 11 (write 11).
> Result: 11000 (base 2).

## Key Points to Remember

- The base determines how many unique digits are used.
- Place values in base *b* are powers of *b*.
- To convert to base 10: expand using place values and sum.
- To convert from base 10: repeatedly divide by the new base and read remainders upward.
- In any base *b*, valid digits range from 0 to (b − 1).

## Topic Summary

Number bases are alternative ways of representing quantities. The decimal system is everyday, but binary, octal and hexadecimal are vital in computing. Mastering conversion between bases builds a foundation for understanding digital systems and strengthens algebraic manipulation skills.')
  on conflict (topic_id) do update set content = excluded.content, updated_at = now();

  insert into public.formulas (topic_id, name, expression, variables, when_to_use, worked_example) values
  (v_topic_id, 'Place Value Expansion', 'd_n × b^n + d_(n-1) × b^(n-1) + ... + d_0 × b^0',
   '[{"symbol":"b","meaning":"the number base (radix)"},{"symbol":"d_i","meaning":"the digit at position i, counting from 0 at the right"},{"symbol":"n","meaning":"the highest power (position of the leftmost digit)"}]',
   'Use this to convert a number from any base b into base 10 (decimal).',
   'Convert 231 in base 4 to base 10: 2×16 + 3×4 + 1×1 = 32 + 12 + 1 = 45.'),

  (v_topic_id, 'Base Conversion by Repeated Division', 'Decimal ÷ b → quotient, remainder (repeat until quotient = 0)',
   '[{"symbol":"Decimal","meaning":"the number in base 10 to be converted"},{"symbol":"b","meaning":"the target base"},{"symbol":"remainder","meaning":"the digit of the new base, read from last to first"}]',
   'Use this to convert a base-10 number into any other base b.',
   'Convert 45 to base 2: remainders of 45÷2 repeated are 1,0,1,1,0,1 read upward giving 101101 in base 2.');

  insert into public.flashcards (topic_id, subject_id, class_id, front, back) values
  (v_topic_id, v_math_id, v_class_id, 'What digits are used in the binary number system?', '0 and 1 only.'),
  (v_topic_id, v_math_id, v_class_id, 'What is the place value of the digit 3 in 231 base 4?', '3 × 4^1 = 12.'),
  (v_topic_id, v_math_id, v_class_id, 'How do you convert a base-10 number to another base?', 'Repeatedly divide by the target base and record the remainders, reading them from last to first.'),
  (v_topic_id, v_math_id, v_class_id, 'What is 45 (base 10) in binary?', '101101 base 2.');


  -- ===== Topic 2: Indices and Standard Form =====
  insert into public.topics (subject_id, class_id, title, slug, description, order_index, is_published)
  values (v_math_id, v_class_id, 'Indices and Standard Form', 'indices-standard-form',
          'Laws of indices, negative and fractional indices, and expressing numbers in standard form.',
          2, true)
  on conflict (class_id, subject_id, slug) do update set
    title = excluded.title, description = excluded.description,
    order_index = excluded.order_index, is_published = excluded.is_published
  returning id into v_topic_id;

  insert into public.study_notes (topic_id, content) values (v_topic_id,
'## Introduction

Indices (also called exponents or powers) provide a compact way of writing repeated multiplication. The expression a^n means a multiplied by itself n times. Standard form (scientific notation) uses indices to write very large or very small numbers conveniently.

## Learning Objectives

By the end of this lesson, you will be able to:

1. Apply the laws of indices to simplify expressions.
2. Work with negative and fractional indices.
3. Express numbers in standard form.
4. Perform calculations with numbers in standard form.

## Definitions

- **Index (exponent):** The small raised number that shows how many times a base is multiplied by itself.
- **Base:** The number being raised to a power.
- **Standard form:** A number written as A × 10^n, where 1 ≤ A < 10 and n is an integer.

## The Laws of Indices

Let a and b be positive real numbers, and m, n be integers.

1. **Multiplication (same base):** a^m × a^n = a^(m+n)
2. **Division (same base):** a^m ÷ a^n = a^(m−n)
3. **Power of a power:** (a^m)^n = a^(mn)
4. **Power of a product:** (ab)^n = a^n b^n
5. **Power of a fraction:** (a/b)^n = a^n / b^n
6. **Zero index:** a^0 = 1  (where a ≠ 0)
7. **Negative index:** a^(−n) = 1 / a^n
8. **Fractional index:** a^(1/n) = ⁿ√a  and  a^(m/n) = (ⁿ√a)^m

### Worked Example 1

Simplify 2^3 × 2^4.

> 2^3 × 2^4 = 2^(3+4) = 2^7 = 128

### Worked Example 2

Simplify (3^2)^3.

> (3^2)^3 = 3^(2×3) = 3^6 = 729

### Worked Example 3

Evaluate 16^(−1/2).

> 16^(−1/2) = 1 / 16^(1/2) = 1 / √16 = 1/4

## Standard Form

A number is in standard form when written as A × 10^n, where:

- 1 ≤ A < 10
- n is a positive or negative integer

### Converting to Standard Form

- **Large numbers:** Move the decimal point left until only one non-zero digit remains to its left. The number of moves is the positive power of 10.
- **Small numbers:** Move the decimal point right; the power of 10 is negative.

### Worked Example

Express 0.000035 in standard form.

> Move the decimal 5 places to the right: 0.000035 = 3.5 × 10^(−5).

### Worked Example

Express 24,500 in standard form.

> Move the decimal 4 places to the left: 24,500 = 2.45 × 10^4.

## Key Points to Remember

- Same base, multiply then add indices; same base, divide then subtract indices.
- A negative index means "one over".
- A fractional index is a root.
- In standard form A × 10^n, A must be between 1 (inclusive) and 10 (exclusive).

## Topic Summary

Indices simplify repeated multiplication and follow consistent laws. Standard form leverages powers of 10 to express very large or very small numbers compactly, which is essential in science and engineering.')
  on conflict (topic_id) do update set content = excluded.content, updated_at = now();

  insert into public.formulas (topic_id, name, expression, variables, when_to_use, worked_example) values
  (v_topic_id, 'Multiplication Law of Indices', 'a^m × a^n = a^(m+n)',
   '[{"symbol":"a","meaning":"the common base (positive real number)"},{"symbol":"m, n","meaning":"the exponents"}]',
   'Use when multiplying powers that share the same base.',
   '2^3 × 2^4 = 2^7 = 128.'),

  (v_topic_id, 'Division Law of Indices', 'a^m ÷ a^n = a^(m−n)',
   '[{"symbol":"a","meaning":"the common base (a ≠ 0)"},{"symbol":"m, n","meaning":"the exponents"}]',
   'Use when dividing powers that share the same base.',
   '5^6 ÷ 5^2 = 5^4 = 625.'),

  (v_topic_id, 'Negative Index', 'a^(−n) = 1 / a^n',
   '[{"symbol":"a","meaning":"the base (a ≠ 0)"},{"symbol":"n","meaning":"the positive exponent"}]',
   'Use to rewrite a negative power as a fraction.',
   '2^(−3) = 1 / 2^3 = 1/8.'),

  (v_topic_id, 'Fractional Index', 'a^(m/n) = (ⁿ√a)^m',
   '[{"symbol":"a","meaning":"the base (a ≥ 0 for even n)"},{"symbol":"m","meaning":"numerator of the exponent"},{"symbol":"n","meaning":"denominator; the root to take"}]',
   'Use to convert a fractional power into a root raised to a power.',
   '27^(2/3) = (³√27)² = 3² = 9.'),

  (v_topic_id, 'Standard Form', 'A × 10^n  where 1 ≤ A < 10',
   '[{"symbol":"A","meaning":"a number between 1 (inclusive) and 10 (exclusive)"},{"symbol":"n","meaning":"an integer (positive for large, negative for small numbers)"}]',
   'Use to express very large or very small numbers compactly.',
   '24,500 = 2.45 × 10^4;  0.000035 = 3.5 × 10^(−5).');

  insert into public.flashcards (topic_id, subject_id, class_id, front, back) values
  (v_topic_id, v_math_id, v_class_id, 'What is a^m × a^n equal to?', 'a^(m+n) — add the indices when the bases are the same.'),
  (v_topic_id, v_math_id, v_class_id, 'What does a zero index equal?', 'a^0 = 1 (for any a ≠ 0).'),
  (v_topic_id, v_math_id, v_class_id, 'How is a negative index rewritten?', 'a^(−n) = 1 / a^n.'),
  (v_topic_id, v_math_id, v_class_id, 'In standard form A × 10^n, what are the rules for A and n?', '1 ≤ A < 10 and n is an integer.');


  -- ===== Topic 3: Logarithms =====
  insert into public.topics (subject_id, class_id, title, slug, description, order_index, is_published)
  values (v_math_id, v_class_id, 'Logarithms', 'logarithms',
          'Definition of logarithms, laws of logarithms and solving logarithmic equations.',
          3, true)
  on conflict (class_id, subject_id, slug) do update set
    title = excluded.title, description = excluded.description,
    order_index = excluded.order_index, is_published = excluded.is_published
  returning id into v_topic_id;

  insert into public.study_notes (topic_id, content) values (v_topic_id,
'## Introduction

A logarithm answers the question: "to what power must a given base be raised to produce a particular number?" Logarithms are the inverse of indices and are widely used in calculations involving very large or very small numbers, as well as in science and engineering.

## Learning Objectives

By the end of this lesson, you will be able to:

1. Define a logarithm and convert between index and logarithmic form.
2. Apply the laws of logarithms.
3. Solve simple logarithmic equations.
4. Use logarithms to simplify calculations.

## Definitions

- **Logarithm:** If a^x = N, then log_a N = x, where a > 0, a ≠ 1, and N > 0.
- **Common logarithm:** A logarithm with base 10, written simply as log N (base omitted).
- **Natural logarithm:** A logarithm with base e (approximately 2.718), written as ln N.

## Relationship Between Indices and Logarithms

The logarithmic form and index form are two ways of writing the same relationship:

> Index form: a^x = N
> Logarithm form: log_a N = x

### Example

Since 2^3 = 8, we have log_2 8 = 3.

Since 10^2 = 100, we have log_10 100 = 2.

## Laws of Logarithms

Let M, N > 0 and a > 0, a ≠ 1.

1. **Product law:** log_a (MN) = log_a M + log_a N
2. **Quotient law:** log_a (M/N) = log_a M − log_a N
3. **Power law:** log_a (M^n) = n log_a M
4. **Root law:** log_a (ⁿ√M) = (1/n) log_a M
5. **Logarithm of 1:** log_a 1 = 0
6. **Logarithm of the base:** log_a a = 1
7. **Change of base:** log_b M = (log_a M) / (log_a b)

### Worked Example 1

Simplify log_10 25 + log_10 4.

> log_10 25 + log_10 4 = log_10 (25 × 4) = log_10 100 = 2.

### Worked Example 2

Solve log_2 (x + 6) = 3.

> Convert to index form: 2^3 = x + 6
> 8 = x + 6
> x = 2.

### Worked Example 3

Evaluate log_3 81.

> 3^4 = 81, so log_3 81 = 4.

## Key Points to Remember

- Logarithms and indices are inverse operations.
- The argument of a logarithm must be positive.
- The product law turns multiplication into addition; the quotient law turns division into subtraction.
- The power law brings an exponent to the front as a multiplier.

## Topic Summary

Logarithms translate exponential relationships into linear ones, simplifying complex multiplication and division into addition and subtraction. Understanding the laws of logarithms is essential for solving exponential equations and for scientific calculations.')
  on conflict (topic_id) do update set content = excluded.content, updated_at = now();

  insert into public.formulas (topic_id, name, expression, variables, when_to_use, worked_example) values
  (v_topic_id, 'Definition of a Logarithm', 'If a^x = N  then  log_a N = x',
   '[{"symbol":"a","meaning":"the base (a > 0, a ≠ 1)"},{"symbol":"N","meaning":"the number (N > 0)"},{"symbol":"x","meaning":"the logarithm — the power to which a is raised"}]',
   'Use to convert between index and logarithm form.',
   'Since 2^3 = 8, log_2 8 = 3.'),

  (v_topic_id, 'Product Law of Logarithms', 'log_a (MN) = log_a M + log_a N',
   '[{"symbol":"a","meaning":"the base"},{"symbol":"M, N","meaning":"positive numbers being multiplied"}]',
   'Use to combine the logs of multiplied quantities into a sum.',
   'log 25 + log 4 = log(100) = 2.'),

  (v_topic_id, 'Quotient Law of Logarithms', 'log_a (M/N) = log_a M − log_a N',
   '[{"symbol":"a","meaning":"the base"},{"symbol":"M","meaning":"the numerator (positive)"},{"symbol":"N","meaning":"the denominator (positive)"}]',
   'Use to combine the logs of divided quantities into a difference.',
   'log 100 − log 10 = log(10) = 1.'),

  (v_topic_id, 'Power Law of Logarithms', 'log_a (M^n) = n × log_a M',
   '[{"symbol":"a","meaning":"the base"},{"symbol":"M","meaning":"the positive number being raised to a power"},{"symbol":"n","meaning":"the exponent"}]',
   'Use to bring an exponent down as a multiplier in front of a logarithm.',
   'log (8^2) = 2 × log 8 = 2 × 0.903 = 1.806.'),

  (v_topic_id, 'Change of Base', 'log_b M = (log_a M) / (log_a b)',
   '[{"symbol":"a","meaning":"any convenient new base"},{"symbol":"b","meaning":"the original base"},{"symbol":"M","meaning":"the number"}]',
   'Use to compute a logarithm in a base your calculator or table does not support directly.',
   'log_2 16 = (log 16) / (log 2) = 1.204 / 0.301 = 4.');

  insert into public.flashcards (topic_id, subject_id, class_id, front, back) values
  (v_topic_id, v_math_id, v_class_id, 'If a^x = N, what is the logarithmic form?', 'log_a N = x.'),
  (v_topic_id, v_math_id, v_class_id, 'State the product law of logarithms.', 'log_a (MN) = log_a M + log_a N.'),
  (v_topic_id, v_math_id, v_class_id, 'What is log_a (1)?', '0 — the logarithm of 1 in any base is 0.'),
  (v_topic_id, v_math_id, v_class_id, 'Evaluate log_3 81.', '4, because 3^4 = 81.');

end $$;
