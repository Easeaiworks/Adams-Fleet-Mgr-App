# Fleet Pilot

Fleet management application for tracking vehicles, expenses, inspections, tire management, and reporting.

## Tech Stack

- **Frontend**: React 18, TypeScript, Vite
- **UI**: shadcn/ui, Tailwind CSS, Recharts
- **Backend**: Supabase (Auth, Database, Edge Functions)
- **AI**: OpenAI-compatible API for receipt scanning (configurable endpoint)

## Getting Started

### Prerequisites

- Node.js 18+ and npm

### Installation

```sh
git clone <YOUR_GIT_URL>
cd Fleet-pilot
npm install
npm run dev
```

The dev server will start at `http://localhost:8080`.

### Environment Variables

For the receipt scanning edge function, set these in your Supabase project secrets:

- `AI_API_KEY` — Your OpenAI-compatible API key (OpenAI, OpenRouter, Google AI, etc.)
- `AI_API_URL` — (Optional) Custom API endpoint. Defaults to OpenRouter.

## Scripts

- `npm run dev` — Start development server
- `npm run build` — Production build
- `npm run preview` — Preview production build
- `npm run lint` — Run ESLint

## Project Structure

- `src/` — React application source
  - `pages/` — Route pages (Expenses, Reports, Vehicle Inspection, etc.)
  - `hooks/` — Custom React hooks (auth, roles, toast, etc.)
  - `lib/` — Utility functions
  - `utils/` — Helpers (PDF parsing, import mapping, etc.)
- `supabase/` — Supabase config, migrations, and edge functions
- `public/` — Static assets
