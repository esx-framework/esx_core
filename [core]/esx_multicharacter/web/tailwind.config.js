/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        orange: {
          500: '#FF9800',
          600: '#F57C00',
        },
        neutral: {
          800: '#262626',
          900: '#1c1c1c',
        }
      },
      animation: {
        'slide-in': 'slideIn 0.5s ease-out forwards',
        'slide-down': 'slideDown 0.3s ease-out forwards',
      },
      keyframes: {
        slideIn: {
          '0%': { transform: 'translateX(-100%)', opacity: 0 },
          '100%': { transform: 'translateX(0)', opacity: 1 },
        },
        slideDown: {
          '0%': { maxHeight: '0', opacity: 0, transform: 'translateY(-10px)' },
          '100%': { maxHeight: '500px', opacity: 1, transform: 'translateY(0)' },
        },
      },
    },
  },
  plugins: [],
};