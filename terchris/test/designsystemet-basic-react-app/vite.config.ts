import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [
    react({
      jsxRuntime: 'automatic',
      babel: {
        plugins: [
          ['@babel/plugin-transform-react-jsx', { runtime: 'automatic' }],
        ],
      },
    }),
    tsconfigPaths(),
  ],
  server: {
    port: 3000,
    open: true,
    host: true,
    strictPort: true,
    watch: {
      usePolling: true,
    },
  },
  build: {
    sourcemap: true,
    minify: 'terser',
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          designSystem: [
            '@digdir/designsystemet-css',
            '@digdir/designsystemet-react',
            '@digdir/designsystemet-theme',
          ],
        },
      },
    },
  },
  optimizeDeps: {
    include: ['react', 'react-dom'],
    exclude: ['@digdir/designsystemet-css', '@digdir/designsystemet-react', '@digdir/designsystemet-theme'],
  },
});