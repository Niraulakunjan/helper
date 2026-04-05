import React from 'react';
import { motion } from 'framer-motion';

interface SkeletonProps {
  type?: 'rect' | 'circle' | 'text';
  width?: string; // e.g., '100%', '200px'
  height?: string; // e.g., '20px'
  className?: string;
}

export const Skeleton: React.FC<SkeletonProps> = ({ type = 'rect', width = '100%', height = '1rem', className = '' }) => {
  const baseClass = `bg-white/10 animate-pulse rounded ${className}`;
  const style = { width, height };
  if (type === 'circle') {
    return <div className={`rounded-full ${baseClass}`} style={style} />;
  }
  if (type === 'text') {
    return <div className={baseClass} style={style} />;
  }
  // rect
  return <div className={baseClass} style={style} />;
};

// Example usage within a motion wrapper for smooth appearance
export const SkeletonWrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ duration: 0.2 }}>
    {children}
  </motion.div>
);
