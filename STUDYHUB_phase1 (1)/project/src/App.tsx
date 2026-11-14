import { useMemo, useState } from 'react';
import { motion } from 'framer-motion';
import {
  Activity, ArrowRight, Atom, Award, BookOpen, BookOpenCheck,
  Bookmark, CalendarDays, CheckCircle2, ChevronDown, ChevronRight, Clock3,
  GraduationCap, LayoutDashboard, LibraryBig, Menu, Search, Settings,
  ShieldCheck, Sparkles, Target, TrendingUp, X, Zap, FlaskConical, Leaf,
  Calculator, Globe2, Landmark, Scale, Laptop, BookMarked,
  CircleHelp, Bell, FunctionSquare, Wheat
} from 'lucide-react';

type Subject = {
  name: string;
  category: string;
  description: string;
  icon: typeof BookOpen;
  color: string;
  topics: number;
};

const subjects: Subject[] = [
  { name: 'Mathematics', category: 'Science & Mathematics', description: 'Build confidence with numbers, algebra, geometry and more.', icon: Calculator, color: 'blue', topics: 32 },
  { name: 'English Language', category: 'Languages', description: 'Improve grammar, comprehension, writing and oral English.', icon: BookOpen, color: 'violet', topics: 28 },
  { name: 'Further Mathematics', category: 'Science & Mathematics', description: 'Explore advanced mathematics, calculus, vectors and matrices.', icon: FunctionSquare, color: 'cyan', topics: 24 },
  { name: 'Biology', category: 'Sciences', description: 'Understand living organisms and the world around you.', icon: Leaf, color: 'green', topics: 26 },
  { name: 'Chemistry', category: 'Sciences', description: 'Learn about matter, reactions, elements and compounds.', icon: FlaskConical, color: 'orange', topics: 25 },
  { name: 'Physics', category: 'Sciences', description: 'Explore energy, motion, forces, waves and electricity.', icon: Atom, color: 'pink', topics: 27 },
  { name: 'Economics', category: 'Social Sciences', description: 'Understand markets, choices, production and distribution.', icon: TrendingUp, color: 'teal', topics: 22 },
  { name: 'Government', category: 'Social Sciences', description: 'Explore political systems, institutions and citizenship.', icon: Landmark, color: 'amber', topics: 20 },
  { name: 'Geography', category: 'Social Sciences', description: 'Discover the earth, its people, resources and environments.', icon: Globe2, color: 'sky', topics: 23 },
  { name: 'Civic Education', category: 'Humanities', description: 'Learn about rights, responsibilities and good citizenship.', icon: Scale, color: 'rose', topics: 18 },
  { name: 'Agricultural Science', category: 'Sciences', description: 'Study crops, livestock, soil and modern agriculture.', icon: Wheat, color: 'lime', topics: 19 },
  { name: 'Computer Studies', category: 'Technology', description: 'Understand computers, digital systems and information technology.', icon: Laptop, color: 'indigo', topics: 18 },
];

const navItems = [
  { label: 'Overview', icon: LayoutDashboard },
  { label: 'My subjects', icon: LibraryBig },
  { label: 'Study centre', icon: BookOpenCheck },
  { label: 'Flashcards', icon: Bookmark },
  { label: 'Practice centre', icon: Target },
  { label: 'Study planner', icon: CalendarDays },
];

const colorClasses: Record<string, string> = {
  blue: 'bg-blue-50 text-blue-700', violet: 'bg-violet-50 text-violet-700',
  cyan: 'bg-cyan-50 text-cyan-700', green: 'bg-emerald-50 text-emerald-700',
  orange: 'bg-orange-50 text-orange-700', pink: 'bg-pink-50 text-pink-700',
  teal: 'bg-teal-50 text-teal-700', amber: 'bg-amber-50 text-amber-700',
  sky: 'bg-sky-50 text-sky-700', rose: 'bg-rose-50 text-rose-700',
  lime: 'bg-lime-50 text-lime-700', indigo: 'bg-indigo-50 text-indigo-700',
};

function App() {
  const [activeNav, setActiveNav] = useState('Overview');
  const [selectedClass, setSelectedClass] = useState('SS2');
  const [classMenuOpen, setClassMenuOpen] = useState(false);
  const [search, setSearch] = useState('');
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [showAllSubjects, setShowAllSubjects] = useState(false);
  const [notice, setNotice] = useState('');

  const filteredSubjects = useMemo(() => subjects.filter((subject) =>
    `${subject.name} ${subject.category}`.toLowerCase().includes(search.toLowerCase())
  ), [search]);

  const visibleSubjects = showAllSubjects ? filteredSubjects : filteredSubjects.slice(0, 6);

  const chooseNav = (label: string) => {
    setActiveNav(label);
    setMobileMenuOpen(false);
    if (label !== 'Overview' && label !== 'My subjects') {
      setNotice(`${label} is part of the next development stage. Your project structure is ready for it.`);
    } else {
      setNotice('');
    }
  };

  return (
    <div className="min-h-screen bg-[#f6f8fc] text-slate-800">
      <div className="flex min-h-screen">
        <aside className={`${mobileMenuOpen ? 'fixed inset-y-0 left-0 z-50 flex' : 'hidden'} w-[258px] shrink-0 flex-col border-r border-slate-200 bg-white px-5 py-6 lg:sticky lg:top-0 lg:flex lg:h-screen`}>
          <div className="mb-10 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-blue-700 text-white shadow-lg shadow-blue-200">
                <GraduationCap size={25} strokeWidth={2.2} />
              </div>
              <div>
                <p className="text-xl font-extrabold tracking-tight text-slate-900">study<span className="text-blue-700">hub</span></p>
                <p className="text-[10px] font-semibold uppercase tracking-[.19em] text-slate-400">Learn. Practise. Excel.</p>
              </div>
            </div>
            <button onClick={() => setMobileMenuOpen(false)} className="rounded-lg p-2 text-slate-500 lg:hidden" aria-label="Close menu"><X size={20} /></button>
          </div>

          <div className="mb-7">
            <p className="mb-3 px-3 text-[10px] font-bold uppercase tracking-[.18em] text-slate-400">Workspace</p>
            <nav className="space-y-1">
              {navItems.map(({ label, icon: Icon }) => (
                <button key={label} onClick={() => chooseNav(label)} className={`flex w-full items-center gap-3 rounded-xl px-3 py-3 text-left text-[13px] font-semibold transition ${activeNav === label ? 'bg-blue-700 text-white shadow-md shadow-blue-100' : 'text-slate-500 hover:bg-slate-100 hover:text-slate-900'}`}>
                  <Icon size={18} /> {label}
                  {label === 'Practice centre' && <span className={`ml-auto rounded-md px-1.5 py-0.5 text-[9px] ${activeNav === label ? 'bg-white/20 text-white' : 'bg-amber-100 text-amber-700'}`}>NEW</span>}
                </button>
              ))}
            </nav>
          </div>

          <div className="mb-7">
            <p className="mb-3 px-3 text-[10px] font-bold uppercase tracking-[.18em] text-slate-400">Personal</p>
            <button onClick={() => chooseNav('Bookmarks')} className="flex w-full items-center gap-3 rounded-xl px-3 py-3 text-left text-[13px] font-semibold text-slate-500 transition hover:bg-slate-100 hover:text-slate-900"><BookMarked size={18} /> Bookmarks</button>
            <button onClick={() => chooseNav('Settings')} className="flex w-full items-center gap-3 rounded-xl px-3 py-3 text-left text-[13px] font-semibold text-slate-500 transition hover:bg-slate-100 hover:text-slate-900"><Settings size={18} /> Settings</button>
          </div>

          <div className="mt-auto rounded-2xl bg-gradient-to-br from-blue-700 to-indigo-800 p-4 text-white">
            <div className="mb-3 flex h-9 w-9 items-center justify-center rounded-xl bg-white/15"><Sparkles size={19} /></div>
            <p className="text-sm font-bold">Small steps, big results.</p>
            <p className="mt-1 text-xs leading-5 text-blue-100">A little learning every day adds up to something great.</p>
            <div className="mt-4 flex items-center gap-2 text-[10px] font-semibold text-blue-100"><ShieldCheck size={13} /> Your learning journey starts here</div>
          </div>
        </aside>

        {mobileMenuOpen && <button className="fixed inset-0 z-40 bg-slate-950/30 lg:hidden" onClick={() => setMobileMenuOpen(false)} aria-label="Close navigation overlay" />}

        <main className="min-w-0 flex-1">
          <header className="sticky top-0 z-30 flex h-[76px] items-center justify-between border-b border-slate-200/80 bg-white/90 px-4 backdrop-blur-xl sm:px-7 xl:px-10">
            <div className="flex items-center gap-3">
              <button onClick={() => setMobileMenuOpen(true)} className="rounded-xl p-2 text-slate-600 hover:bg-slate-100 lg:hidden" aria-label="Open menu"><Menu size={21} /></button>
              <div>
                <p className="text-xs font-medium text-slate-400">Wednesday, 12 November 2026</p>
                <p className="text-sm font-bold text-slate-800">{activeNav === 'Overview' ? 'Your learning overview' : activeNav}</p>
              </div>
            </div>
            <div className="flex items-center gap-2 sm:gap-4">
              <div className="relative hidden sm:block">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={16} />
                <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search subjects..." className="h-10 w-48 rounded-xl border border-slate-200 bg-slate-50 pl-9 pr-3 text-xs outline-none transition focus:border-blue-400 focus:bg-white xl:w-60" />
              </div>
              <button className="relative rounded-xl border border-slate-200 p-2.5 text-slate-500 hover:bg-slate-50" aria-label="Notifications"><Bell size={18} /><span className="absolute right-2 top-2 h-1.5 w-1.5 rounded-full bg-orange-500 ring-2 ring-white" /></button>
              <div className="flex items-center gap-2 border-l border-slate-200 pl-3 sm:pl-4">
                <div className="flex h-9 w-9 items-center justify-center rounded-full bg-blue-100 text-xs font-extrabold text-blue-700">ST</div>
                <div className="hidden sm:block"><p className="text-xs font-bold text-slate-800">Student</p><p className="text-[10px] text-slate-400">Learner account</p></div>
                <ChevronDown size={15} className="hidden text-slate-400 sm:block" />
              </div>
            </div>
          </header>

          <div className="mx-auto max-w-[1440px] px-4 py-7 sm:px-7 xl:px-10 xl:py-9">
            {notice && (
              <div className="mb-5 flex items-start justify-between gap-3 rounded-xl border border-blue-100 bg-blue-50 px-4 py-3 text-sm text-blue-800">
                <p>{notice}</p><button onClick={() => setNotice('')} aria-label="Dismiss"><X size={17} /></button>
              </div>
            )}

            <section className="mb-8 flex flex-col justify-between gap-5 xl:flex-row xl:items-end">
              <div>
                <div className="mb-3 inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-3 py-1 text-[10px] font-bold uppercase tracking-[.12em] text-blue-700"><Sparkles size={12} /> Your learning space</div>
                <h1 className="text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Keep moving forward<span className="text-blue-700">.</span></h1>
                <p className="mt-2 max-w-xl text-sm leading-6 text-slate-500">Build your knowledge one topic at a time. Pick up where you left off or explore something new today.</p>
              </div>
              <div className="relative">
                <button onClick={() => setClassMenuOpen(!classMenuOpen)} className="flex items-center gap-3 rounded-xl border border-slate-200 bg-white px-4 py-3 shadow-sm transition hover:border-blue-300">
                  <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-indigo-50 text-indigo-700"><GraduationCap size={19} /></div>
                  <div className="text-left"><p className="text-[10px] font-semibold uppercase tracking-wider text-slate-400">Current class</p><p className="text-sm font-bold text-slate-800">{selectedClass}</p></div>
                  <ChevronDown size={16} className="ml-3 text-slate-400" />
                </button>
                {classMenuOpen && <div className="absolute right-0 top-full z-20 mt-2 w-full overflow-hidden rounded-xl border border-slate-200 bg-white p-1 shadow-xl">{['SS1', 'SS2', 'SS3'].map((level) => <button key={level} onClick={() => { setSelectedClass(level); setClassMenuOpen(false); }} className={`block w-full rounded-lg px-3 py-2 text-left text-sm font-semibold hover:bg-blue-50 ${selectedClass === level ? 'text-blue-700' : 'text-slate-600'}`}>{level}</button>)}</div>}
              </div>
            </section>

            <section className="mb-8 grid grid-cols-2 gap-3 xl:grid-cols-4 xl:gap-4">
              {[
                { label: 'Subjects to explore', value: '22', note: 'Across your class', icon: LibraryBig, tint: 'bg-blue-50 text-blue-700' },
                { label: 'Topics completed', value: '0', note: 'Your journey starts here', icon: CheckCircle2, tint: 'bg-emerald-50 text-emerald-700' },
                { label: 'Study time', value: '0h 00m', note: 'Keep building the habit', icon: Clock3, tint: 'bg-violet-50 text-violet-700' },
                { label: 'Practice score', value: '—', note: 'Take your first practice', icon: Award, tint: 'bg-amber-50 text-amber-700' },
              ].map(({ label, value, note, icon: Icon, tint }) => (
                <motion.div key={label} initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} className="rounded-2xl border border-slate-200/80 bg-white p-4 shadow-sm sm:p-5">
                  <div className="mb-4 flex items-center justify-between"><span className="text-[11px] font-semibold text-slate-500">{label}</span><span className={`flex h-9 w-9 items-center justify-center rounded-xl ${tint}`}><Icon size={18} /></span></div>
                  <p className="text-2xl font-extrabold tracking-tight text-slate-900">{value}</p><p className="mt-1 text-[10px] text-slate-400">{note}</p>
                </motion.div>
              ))}
            </section>

            <section className="mb-8 grid gap-5 xl:grid-cols-[1.55fr_1fr]">
              <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-[#123c91] via-[#1856b8] to-[#3c74dc] p-6 text-white shadow-xl shadow-blue-100 sm:p-8">
                <div className="relative z-10 max-w-lg">
                  <div className="mb-4 inline-flex items-center gap-2 rounded-full bg-white/15 px-3 py-1.5 text-[10px] font-bold uppercase tracking-wider text-blue-50"><Zap size={12} /> Make today count</div>
                  <h2 className="text-2xl font-extrabold leading-tight sm:text-3xl">Your next big result starts with one topic.</h2>
                  <p className="mt-3 max-w-md text-sm leading-6 text-blue-100">Choose a subject, understand the lesson, then test what you know. STUDYHUB keeps your learning organised.</p>
                  <button onClick={() => chooseNav('My subjects')} className="mt-6 inline-flex items-center gap-2 rounded-xl bg-white px-4 py-3 text-xs font-bold text-blue-800 shadow-lg transition hover:-translate-y-0.5 hover:bg-blue-50">Explore subjects <ArrowRight size={15} /></button>
                </div>
                <div className="pointer-events-none absolute -right-10 -top-16 h-72 w-72 rounded-full border-[38px] border-white/10" />
                <div className="pointer-events-none absolute -bottom-28 right-24 h-64 w-64 rounded-full border-[32px] border-white/10" />
                <div className="pointer-events-none absolute right-10 top-10 hidden h-24 w-24 items-center justify-center rounded-3xl border border-white/20 bg-white/10 backdrop-blur sm:flex"><BookOpenCheck size={42} className="text-white/90" /></div>
              </div>

              <div className="rounded-3xl border border-slate-200/80 bg-white p-5 shadow-sm sm:p-6">
                <div className="mb-5 flex items-center justify-between"><div><h3 className="text-sm font-extrabold text-slate-900">Your weekly activity</h3><p className="mt-1 text-[11px] text-slate-400">A fresh week to make progress</p></div><div className="rounded-xl bg-emerald-50 p-2 text-emerald-700"><Activity size={18} /></div></div>
                <div className="flex h-32 items-end justify-between gap-2">
                  {[['M', 22], ['T', 38], ['W', 28], ['T', 52], ['F', 34], ['S', 15], ['S', 10]].map(([day, height], index) => <div key={index} className="flex flex-1 flex-col items-center gap-2"><div className="flex h-24 w-full items-end rounded-lg bg-slate-50"><div className="w-full rounded-lg bg-blue-200" style={{ height: `${height}%` }} /></div><span className="text-[10px] font-medium text-slate-400">{day}</span></div>)}
                </div>
                <div className="mt-4 flex items-center gap-2 rounded-xl bg-slate-50 px-3 py-2.5 text-[11px] text-slate-500"><Target size={15} className="text-blue-600" /> Start a study session to see your activity here.</div>
              </div>
            </section>

            <section className="mb-4">
              <div className="mb-4 flex flex-wrap items-end justify-between gap-3">
                <div><p className="text-[10px] font-bold uppercase tracking-[.16em] text-blue-700">Build your knowledge</p><h2 className="mt-1 text-xl font-extrabold tracking-tight text-slate-900">Explore your subjects</h2><p className="mt-1 text-xs text-slate-500">Choose a subject to discover its topics and lessons.</p></div>
                <button onClick={() => setShowAllSubjects(!showAllSubjects)} className="inline-flex items-center gap-1 text-xs font-bold text-blue-700 hover:text-blue-900">{showAllSubjects ? 'Show less' : 'View all subjects'} <ArrowRight size={14} /></button>
              </div>
              <div className="mb-4 sm:hidden"><div className="relative"><Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={16} /><input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search subjects..." className="input pl-9" /></div></div>
              {visibleSubjects.length > 0 ? <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-3">
                {visibleSubjects.map(({ name, category, description, icon: Icon, color, topics }, index) => (
                  <motion.button key={name} initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: index * .035 }} onClick={() => { setNotice(`${name} for ${selectedClass} selected. Topic browsing will be connected to your curriculum database in the next stage.`); setActiveNav('My subjects'); }} className="group rounded-2xl border border-slate-200/80 bg-white p-4 text-left shadow-sm transition hover:-translate-y-1 hover:border-blue-200 hover:shadow-lg hover:shadow-blue-50 sm:p-5">
                    <div className="mb-4 flex items-center justify-between"><span className={`flex h-11 w-11 items-center justify-center rounded-2xl ${colorClasses[color]}`}><Icon size={21} /></span><span className="flex items-center gap-1 text-[10px] font-semibold text-slate-400">{topics} topics <ChevronRight size={13} className="transition group-hover:translate-x-1" /></span></div>
                    <p className="text-sm font-extrabold text-slate-900">{name}</p><p className="mt-1 text-[10px] font-semibold text-blue-700">{category}</p><p className="mt-3 text-xs leading-5 text-slate-500">{description}</p>
                  </motion.button>
                ))}
              </div> : <div className="rounded-2xl border border-dashed border-slate-300 bg-white p-10 text-center"><CircleHelp className="mx-auto mb-2 text-slate-400" /><p className="text-sm font-semibold text-slate-700">No subjects found</p><p className="mt-1 text-xs text-slate-400">Try another search term.</p></div>}
            </section>

            <footer className="mt-10 flex flex-col justify-between gap-2 border-t border-slate-200 py-5 text-[10px] text-slate-400 sm:flex-row"><p>© 2026 STUDYHUB. Learn at your pace.</p><p>Built to help you learn, revise and excel.</p></footer>
          </div>
        </main>
      </div>
    </div>
  );
}

export default App;
