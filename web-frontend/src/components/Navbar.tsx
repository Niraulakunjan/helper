import { useState } from 'react';
import { Sparkles, Menu, X } from 'lucide-react';
import { Link } from 'react-router-dom';

const Navbar = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  return (
    <nav className="sticky top-0 z-50 glass-card mx-4 my-4 px-6 py-3 flex items-center justify-between rounded-full bg-white/70">
      <Link to="/" className="flex items-center gap-2">
        <div className="w-10 h-10 bg-primary rounded-full flex items-center justify-center">
          <Sparkles className="text-white w-6 h-6" />
        </div>
        <span className="text-xl font-bold tracking-tight">HouseHelper</span>
      </Link>

      <div className="hidden md:flex items-center gap-8">
        <Link to="/" className="hover:text-primary transition-colors">Home</Link>
        <Link to="/services" className="hover:text-primary transition-colors">Services</Link>
        <Link to="/about" className="hover:text-primary transition-colors">How it works</Link>
        <Link to="/register-helper" className="hover:text-primary transition-colors">Become a Helper</Link>
      </div>

      <div className="flex items-center gap-4">
        <Link to="/login" className="hidden md:block hover:text-primary transition-colors">Login</Link>
        <Link to="/register" className="btn-primary no-underline text-white">Get Started</Link>
        <button className="md:hidden" onClick={() => setIsMenuOpen(!isMenuOpen)}>
          {isMenuOpen ? <X /> : <Menu />}
        </button>
      </div>
    </nav>
  );
};

export default Navbar;
