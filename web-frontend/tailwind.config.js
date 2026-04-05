/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#00D4AA',
        secondary: '#7B61FF',
        background: '#0B0E14',
        surface: 'rgba(23, 28, 38, 0.6)',
        error: '#FF4B5C',
        border: 'rgba(255,255,255,0.08)',
        'text-muted': '#94A3B8',
        'text-dim': '#475569',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
        heading: ['Outfit', 'sans-serif'],
      },
      backdropBlur: {
        xl: '24px',
      },
      borderRadius: {
        '2xl': '1rem',
        '3xl': '1.5rem',
        '4xl': '2rem',
      },
      boxShadow: {
        'primary': '0 4px 24px rgba(0,212,170,0.25)',
        'secondary': '0 4px 24px rgba(123,97,255,0.25)',
        'glass': '0 8px 32px rgba(0,0,0,0.4)',
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-out',
        'slide-up': 'slideUp 0.5s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideUp: {
          '0%': { opacity: '0', transform: 'translateY(30px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
      },
    },
  },
  plugins: [],
};
