// 聊天相关数据模型

export interface Message {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  name?: string;
  avatar?: string;
  timestamp: number;
}

export interface Advisor {
  id: string;
  name: string;
  avatar: string;
  expertise: string;
}

export interface ExampleQuestion {
  text: string;
  question: string;
}

export interface ChatMode {
  id: string;
  name: string;
  description: string;
  icon: string;
  welcomeTitle: string;
  welcomeDesc: string;
  inputPlaceholder: string;
  advisors: Advisor[];
  examples: ExampleQuestion[];
}

export interface StreamChunk {
  type: 'role_start' | 'content' | 'role_end' | 'error';
  role?: string;
  avatar?: string;
  roleId?: string;
  content?: string;
  error?: string;
}
