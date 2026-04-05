import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { MessageSquare, ChevronRight, Clock } from 'lucide-react';
import { chatApi } from '../api';
import { motion } from 'framer-motion';
import { Skeleton } from '../components/Skeleton';

interface Conversation {
  user: { id: number; username: string; role: string };
  last_message: string;
  timestamp: string | null;
  unread: number;
}

const ChatList = () => {
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    chatApi.getConversations()
      .then(res => setConversations(res.data))
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  if (loading) return (
    <div className="container max-w-2xl flex flex-col gap-4">
      {[...Array(4)].map((_, i) => (
        <div key={i} className="glass-card flex items-center gap-4 p-4">
          <Skeleton type="circle" width="3rem" height="3rem" />
          <div className="flex-1 flex flex-col gap-2">
            <Skeleton type="text" width="40%" height="1rem" />
            <Skeleton type="text" width="70%" height="0.75rem" />
          </div>
        </div>
      ))}
    </div>
  );

  return (
    <div className="container max-w-2xl flex flex-col gap-6">
      <div>
        <h1 className="text-3xl font-bold text-white font-heading tracking-tight">Messages</h1>
        <p className="text-text-muted mt-1">All your client conversations</p>
      </div>

      {conversations.length === 0 ? (
        <div className="glass-card flex flex-col items-center justify-center py-20 gap-4 text-center">
          <div className="p-5 bg-white/5 rounded-full">
            <MessageSquare className="w-10 h-10 text-text-dim" />
          </div>
          <h3 className="text-xl font-bold text-white">No conversations yet</h3>
          <p className="text-text-muted max-w-xs text-sm">
            When clients book your services and start chatting, conversations will appear here.
          </p>
        </div>
      ) : (
        <div className="flex flex-col gap-3">
          {conversations.map((conv, i) => (
            <motion.div
              key={conv.user.id}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.06 }}
              onClick={() => navigate(`/chat/${conv.user.id}`)}
              className="glass-card flex items-center gap-4 cursor-pointer hover:border-white/20 transition-all group p-4"
            >
              {/* Avatar */}
              <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-primary to-secondary p-0.5 shrink-0">
                <div className="w-full h-full bg-background rounded-xl flex items-center justify-center font-bold text-primary font-heading uppercase">
                  {conv.user.username[0]}
                </div>
              </div>

              {/* Content */}
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between gap-2">
                  <span className="font-bold text-white truncate">{conv.user.username}</span>
                  {conv.timestamp && (
                    <span className="text-[10px] text-text-dim font-semibold shrink-0 flex items-center gap-1">
                      <Clock className="w-3 h-3" />
                      {new Date(conv.timestamp).toLocaleDateString()}
                    </span>
                  )}
                </div>
                <p className="text-sm text-text-muted truncate mt-0.5">
                  {conv.last_message || 'No messages yet'}
                </p>
              </div>

              {/* Unread badge + arrow */}
              <div className="flex items-center gap-2 shrink-0">
                {conv.unread > 0 && (
                  <span className="min-w-[1.25rem] h-5 px-1.5 bg-primary text-background text-[10px] font-bold rounded-full flex items-center justify-center">
                    {conv.unread}
                  </span>
                )}
                <ChevronRight className="w-4 h-4 text-text-dim group-hover:text-primary transition-colors" />
              </div>
            </motion.div>
          ))}
        </div>
      )}
    </div>
  );
};

export default ChatList;
