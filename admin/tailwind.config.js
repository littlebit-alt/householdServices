/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        dark: {
          100: '#cdd9e5',
          200: '#8b949e',
          300: '#768390',
          400: '#636e7b',
          500: '#444c56',
          600: '#2d333b',
          700: '#22272e',
          800: '#1c2128',
          900: '#161b22',
          950: '#0d1117',
        },
        cyan: {
          400: '#39d4d4',
          500: '#20c9c9',
          600: '#0fb8b8',
        }
      }
    },
  },
  plugins: [],
}