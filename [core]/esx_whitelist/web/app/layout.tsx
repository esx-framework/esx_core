import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'esx_whitelist',
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="en" style={{ background: 'transparent' }}>
      <body className="font-sans" style={{ background: 'transparent' }}>
        {children}
      </body>
    </html>
  )
}