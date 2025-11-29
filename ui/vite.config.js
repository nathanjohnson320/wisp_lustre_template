import { defineConfig } from 'vite'
import tailwindcss from '@tailwindcss/vite'
import gleam from "vite-gleam";

export default defineConfig({
  plugins: [
    gleam(), 
    tailwindcss({
      content: [
        "./src/**/*.{html,gleam,js}",
      ],
      theme: {
        colors: {
          terminalGreen: '#00ff00',
          terminalDark: '#003300',
          terminalBg: '#000000',
          terminalLightGreen: '#33ff33',
        },
        fontFamily: {
          terminal: ['VT323', 'monospace'],
        },
        boxShadow: {
          crtGlow: '0 0 10px rgba(0,255,0,0.3)',
        },
      },
      plugins: [],
    }
  )],
});
