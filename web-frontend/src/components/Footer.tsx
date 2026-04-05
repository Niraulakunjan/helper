import { Sparkles } from 'lucide-react';
import { Link } from 'react-router-dom';

const Footer = () => {
  return (
    <footer className="mt-auto py-12 border-t border-border">
      <div className="container grid grid-cols-1 md:grid-cols-4 gap-12">
        <div className="space-y-4">
          <div className="flex items-center gap-2">
            <Sparkles className="text-primary w-6 h-6" />
            <span className="text-xl font-bold font-['Inter']">HouseHelper</span>
          </div>
          <p className="text-text-muted text-sm">
            The easiest way to find reliable household help for your home and office.
          </p>
        </div>
        <div>
          <h4 className="font-bold mb-4">Company</h4>
          <ul className="space-y-2 text-sm text-text-muted list-none p-0">
            <li><Link to="/about" className="hover:text-primary list-none">About Us</Link></li>
            <li><Link to="/careers" className="hover:text-primary list-none">Careers</Link></li>
            <li><Link to="/contact" className="hover:text-primary list-none">Contact</Link></li>
          </ul>
        </div>
        <div>
          <h4 className="font-bold mb-4">Support</h4>
          <ul className="space-y-2 text-sm text-text-muted list-none p-0">
            <li><Link to="/help" className="hover:text-primary list-none">Help Center</Link></li>
            <li><Link to="/safety" className="hover:text-primary list-none">Safety</Link></li>
            <li><Link to="/terms" className="hover:text-primary list-none">Terms of Service</Link></li>
          </ul>
        </div>
        <div>
          <h4 className="font-bold mb-4">Download App</h4>
          <div className="space-y-3">
            <button className="w-full py-2 bg-slate-900 text-white rounded-lg flex items-center justify-center gap-2">
              <span className="font-bold">App Store</span>
            </button>
            <button className="w-full py-2 bg-slate-900 text-white rounded-lg flex items-center justify-center gap-2">
              <span className="font-bold">Play Store</span>
            </button>
          </div>
        </div>
      </div>
      <div className="container mt-12 pt-8 border-t border-border flex flex-col md:flex-row justify-between items-center gap-4 text-sm text-text-muted">
        <p>© 2026 HouseHelper. All rights reserved.</p>
        <div className="flex gap-6">
          <a href="#" className="hover:text-primary">Twitter</a>
          <a href="#" className="hover:text-primary">Instagram</a>
          <a href="#" className="hover:text-primary">LinkedIn</a>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
