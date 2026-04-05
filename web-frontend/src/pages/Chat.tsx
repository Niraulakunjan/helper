import { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Send, Loader, ArrowLeft, MoreVertical, Shield, Clock, Smile, Paperclip } from 'lucide-react';
import { chatApi } from '../api';
import { useAuth } from '../context/AuthContext';
import { motion, AnimatePresence } from 'framer-motion';

const Chat = () => {
  const { id } = useParams();
  const { user } = useAuth();
  const [messages, setMessages] = useState<any[]>([]);
  const [otherUser, setOtherUser] = useState<any>(null);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(true);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const navigate = useNavigate();

  useEffect(() => {
    fetchChat();
    const interval = setInterval(fetchChat, 3000);
    return () => clearInterval(interval);
  }, [id]);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const fetchChat = async () => {
    try {
      const res = await chatApi.getChatHistory(Number(id));
      setMessages(res.data);
      // Derive the other user's info from message history
      if (!otherUser && res.data.length > 0) {
        const msg = res.data[0];
        // The "other" user is whichever side isn't us
        const other = msg.sender.id === user?.id ? msg.receiver : msg.sender;
        setOtherUser(other);
      } else if (!otherUser) {
        setOtherUser({ username: `User #${id}`, id: Number(id) });
      }
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim()) return;
    const content = input.trim();
    setInput('');
    // Optimistic update — add message immediately so user sees it without waiting for poll
    setMessages((prev: any[]) => [...prev, {
      id: Date.now(),
      sender: user,
      receiver: otherUser,
      content,
      timestamp: new Date().toISOString(),
    }]);
    try {
      await chatApi.sendMessage(Number(id), content);
      // Refresh to get server-confirmed message
      fetchChat();
    } catch (e) {
      console.error(e);
    }
  };

  if (loading && !messages.length) return (
     <div className="flex flex-col items-center justify-center py-40 gap-4">
      <Loader className="w-12 h-12 text-primary animate-spin" />
      <p className="text-text-muted font-heading font-semibold tracking-widest uppercase text-xs">Securing Direct Channel...</p>
    </div>
  );

  return (
    <div className="container max-w-5xl flex flex-col h-[75vh] glass-card p-0 overflow-hidden shadow-2xl relative">
      <div className="absolute top-0 right-0 w-64 h-64 bg-primary/10 rounded-full blur-[100px] pointer-events-none" />
      
      {/* Messenger Header */}
      <header className="p-6 border-b border-white/5 bg-white/[0.02] flex items-center justify-between relative z-10">
        <div className="flex items-center gap-4">
          <button 
            onClick={() => navigate(-1)}
            className="p-2 hover:bg-white/5 rounded-xl text-text-muted"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-primary to-secondary p-0.5">
               <div className="w-full h-full bg-[#0B0E14] rounded-xl flex items-center justify-center font-bold text-primary font-heading uppercase">
                  {otherUser?.username[0]}
               </div>
            </div>
            <div>
               <h3 className="text-white font-bold leading-none">{otherUser?.username}</h3>
               <div className="flex items-center gap-1.5 mt-1.5">
                  <div className="w-1.5 h-1.5 rounded-full bg-primary" />
                  <span className="text-[10px] font-bold text-primary uppercase tracking-widest">Active Insight</span>
               </div>
            </div>
          </div>
        </div>

        <div className="flex items-center gap-3">
           <div className="px-3 py-1.5 bg-white/5 border border-white/10 rounded-lg hidden md:flex items-center gap-2">
              <Shield className="w-3.5 h-3.5 text-primary" />
              <span className="text-[10px] font-bold text-text-muted uppercase tracking-tight">End-to-End Encrypted</span>
           </div>
           <button className="p-2.5 hover:bg-white/5 rounded-xl text-text-muted">
              <MoreVertical className="w-5 h-5" />
           </button>
        </div>
      </header>

      {/* Message Area */}
      <main className="flex-1 overflow-y-auto p-8 flex flex-col gap-6 relative z-10 no-scrollbar">
        <AnimatePresence>
          {messages.map((m, i) => {
            const isMe = m.sender.id === user?.id;
            return (
              <motion.div
                key={m.id || i}
                initial={{ opacity: 0, scale: 0.95, y: 10 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                className={`flex ${isMe ? 'justify-end' : 'justify-start'}`}
              >
                <div className={`max-w-[70%] group relative ${isMe ? 'items-end' : 'items-start'}`}>
                  <div 
                    className={`px-5 py-3.5 rounded-2xl text-sm font-medium shadow-xl ${
                      isMe 
                      ? 'bg-primary text-white rounded-tr-none shadow-primary/10' 
                      : 'bg-white/5 border border-white/5 text-white/90 rounded-tl-none'
                    }`}
                  >
                    {m.content}
                  </div>
                  <div className={`flex items-center gap-2 mt-2 opacity-0 group-hover:opacity-100 transition-opacity ${isMe ? 'justify-end' : 'justify-start'}`}>
                     <Clock className="w-3 h-3 text-text-dim" />
                     <span className="text-[10px] font-bold text-text-dim uppercase">{new Date(m.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                  </div>
                </div>
              </motion.div>
            );
          })}
        </AnimatePresence>
        <div ref={messagesEndRef} />
      </main>

      {/* Modern Input Bar */}
      <footer className="p-6 bg-white/[0.02] border-t border-white/5 relative z-10">
        <form onSubmit={handleSend} className="flex items-center gap-4 bg-[#0B0E14]/40 border border-white/5 rounded-2xl p-2 pl-4 group focus-within:border-primary/30 transition-all shadow-inner">
          <button type="button" className="p-2 text-text-muted hover:text-primary transition-colors">
             <Paperclip className="w-5 h-5" />
          </button>
          <input 
            type="text" 
            className="flex-1 bg-transparent border-none outline-none text-sm font-medium text-white placeholder-text-muted/50 py-3"
            placeholder="Secure message communication..."
            value={input}
            onChange={(e) => setInput(e.target.value)}
          />
          <div className="flex items-center gap-2">
             <button type="button" className="p-2 text-text-muted hover:text-amber-400 transition-colors">
                <Smile className="w-5 h-5" />
             </button>
             <button 
               type="submit"
               disabled={!input.trim()}
               className="p-3 bg-primary text-white rounded-xl shadow-lg shadow-primary/20 hover:scale-105 active:scale-95 disabled:opacity-50 disabled:scale-100 transition-all"
             >
               <Send className="w-5 h-5 fill-white" />
             </button>
          </div>
        </form>
      </footer>
    </div>
  );
};

export default Chat;
