> **Create a single-page personal CV (Curriculum Vitae) using only HTML**, with proper semantic structure, SEO/OG meta tags, and a favicon — **ready for future CSS styling**.

Below is a **detailed, step-by-step construction plan**, including:
- Project definition
- Folder/file structure (tree)
- Development phases
- Checklist per phase
- Final validation & submission prep

---

### 🎯 **1. Task Definition**

**Goal**: Build a **semantic, accessible, SEO-optimized single-page HTML CV** that:
- Represents your personal/professional info
- Uses correct HTML5 semantic tags
- Includes meta tags for SEO and Open Graph
- Has a favicon
- Is structured cleanly for future CSS styling (no inline styles)
- Passes basic HTML validation

**Constraints**:
- **Only HTML** (no CSS file yet — but link a placeholder if needed)
- **Single HTML file** (`index.html`)
- Must include sections: **About, Education, Work Experience, Skills, Languages** (as shown in the example image from the lab PDF)

---

### 🌲 **2. Project Tree Structure**

Since this is **Exercise 1 (HTML-only CV)**, the structure is minimal:

```
lab01-exercise1/
│
├── index.html          ← Your single-page CV (HTML only)
├── favicon.svg         ← Simple SVG favicon (or .ico if preferred)
└── README.md           ← (Optional but recommended) Brief description
```

> 💡 **Note**: You’ll add CSS later in future labs. For now, **no CSS file is required**, but you may include a `<link rel="stylesheet" href="style.css">` as a placeholder if you wish (not mandatory per instructions).

---

### 📋 **3. Development Phases**

#### ✅ **Phase 1: Setup & Planning (15 mins)**
- [ ] Create project folder: `lab01-exercise1`
- [ ] Decide on your **personal content**:
  - Full name
  - Professional title (e.g., "Computer Science Student")
  - Email, phone, location, portfolio/GitHub link
  - Education history (degree, university, years)
  - Work/internship experience
  - Technical & soft skills
  - Languages spoken
- [ ] Sketch a **wireframe** (on paper or digitally) of sections layout

#### ✅ **Phase 2: Build Semantic HTML Structure (45 mins)**
- [ ] Create `index.html`
- [ ] Add **DOCTYPE**, `<html lang="en">`, `<head>`, `<body>`
- [ ] In `<head>`:
  - [ ] `<meta charset="UTF-8">`
  - [ ] `<meta name="viewport" content="width=device-width, initial-scale=1.0">`
  - [ ] `<title>Your Name – CV</title>`
  - [ ] `<meta name="description" content="...">` (SEO)
  - [ ] Open Graph tags (og:title, og:description, og:type, og:url — optional but recommended)
  - [ ] `<link rel="icon" href="favicon.svg">`
- [ ] In `<body>`:
  - Use semantic tags:
    - `<header>` for name/title/contact
    - `<main>` containing:
      - `<section id="about">`
      - `<section id="education">`
      - `<section id="experience">`
      - `<section id="skills">`
      - `<section id="languages">`
    - `<footer>` for copyright or additional notes
  - Use appropriate elements:
    - `<h1>` for your name
    - `<h2>` for section headings
    - `<ul>`/`<ol>` for lists (education, experience, skills)
    - `<p>` for paragraphs
    - `<a>` for links (email, portfolio, etc.)
    - **No div soup!** Prefer `<article>`, `<section>`, etc.

#### ✅ **Phase 3: Add Metadata & Favicon (15 mins)**
- [ ] Create a **simple favicon.svg** (you can use an emoji or text-based SVG):
  ```svg
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
    <text y="0.9em" font-size="90">👤</text>
  </svg>
  ```
- [ ] Save as `favicon.svg`
- [ ] Link in `<head>`: `<link rel="icon" type="image/svg+xml" href="favicon.svg">`
- [ ] Verify all meta tags are present

#### ✅ **Phase 4: Validation & Quality Check (15 mins)**
- [ ] Run your HTML through **[W3C Validator](https://validator.w3.org/)**
- [ ] Fix any errors (e.g., missing alt, improper nesting)
- [ ] Ensure:
  - Only **one `<h1>`**
  - Headings follow logical order (`h1` → `h2` → `h3`)
  - All links are valid (mailto: for email, https:// for web)
  - No inline styles or `<style>` tags (unless placeholder comment)

#### ✅ **Phase 5: Documentation & Submission Prep (10 mins)**
- [ ] Create `README.md` with:
  ```md
  # Lab 1 – Exercise 1: Personal CV (HTML Only)
  - Student: [Your Name]
  - ID: [Your Student ID]
  - Purpose: Semantic HTML CV for Web App Dev Lab
  - Sections: About, Education, Experience, Skills, Languages
  - Ready for CSS styling in future lab.
  ```
- [ ] Test opening `index.html` in browser (should render cleanly, even if unstyled)
- [ ] Take a **screenshot** (for later PDF compilation per Exercise 3)

---

### 🧾 **4. Final Submission Checklist (Per Lab Instructions)**

Ensure your `index.html` includes:
- [ ] Semantic HTML5 structure (`header`, `main`, `section`, `footer`)
- [ ] Single-page layout with required sections
- [ ] SEO meta tags (`<meta name="description">`)
- [ ] Open Graph tags (optional but recommended)
- [ ] Favicon linked properly
- [ ] Valid, clean HTML (W3C compliant)
- [ ] No CSS (or only a commented-out `<link>` for future use)

---

### 📦 **5. Next Steps (For Later Exercises)**

- In **Exercise 2/3**, you’ll:
  - Add CSS styling
  - Create PDF screenshots
  - Build SQL file (unrelated to CV)
  - Zip everything as `fullname_id.zip`
- In **Assignment 1 (2-week project)**, you’ll expand this into a **multi-page site** with forms, iframe, etc.

---
