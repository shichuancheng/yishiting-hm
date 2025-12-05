// 模式配置常量
import { ChatMode, ExampleQuestion, Advisor } from '../models/ChatModels';

const emperorAdvisors: Advisor[] = [
  { id: 'aning', name: '总管·阿宁', avatar: '👔', expertise: '整理问题、总结要点' },
  { id: 'zhuge', name: '军师·诸葛亮', avatar: '🎓', expertise: '战略分析、引经据典' },
  { id: 'sunwu', name: '兵法家·孙武', avatar: '⚔️', expertise: '风险分析、实战策略' },
  { id: 'guanzhong', name: '相国·管仲', avatar: '📜', expertise: '经济民生、资源调配' }
];

const emperorExamples: ExampleQuestion[] = [
  { text: '工作不爽又走不了', question: '我在公司干得不爽，但暂时跳槽无门，怎么办？' },
  { text: '领导老改需求', question: '领导总是临时改需求，我很烦' },
  { text: '犹豫要不要跳槽', question: '想跳槽但又怕新公司不稳定' }
];

const xiyouAdvisors: Advisor[] = [
  { id: 'tangseng', name: '唐三藏', avatar: '🧘', expertise: '价值观引导、长期目标' },
  { id: 'wukong', name: '孙悟空', avatar: '🐵', expertise: '问题拆解、风险识别' },
  { id: 'bajie', name: '猪八戒', avatar: '🐷', expertise: '情绪疏导、自我接纳' },
  { id: 'shaseng', name: '沙僧', avatar: '💪', expertise: '执行落地、任务拆解' }
];

const xiyouExamples: ExampleQuestion[] = [
  { text: '感觉人生好累', question: '最近天天加班，事情又多又杂，感觉日子没盼头' },
  { text: '总是拖延怎么办', question: '我知道该做什么，但就是提不起劲，老是拖延' },
  { text: '被困在烂公司', question: '现在公司氛围差，但外面机会也一般，只能硬撑' }
];

export const CHAT_MODES: ChatMode[] = [
  {
    id: 'emperor',
    name: '三国谋士团',
    description: '化身主公，让名臣为你出谋划策',
    icon: '🏯',
    welcomeTitle: '主公驾到',
    welcomeDesc: '有何烦心事，尽管道来，谋士团随时听候差遣',
    inputPlaceholder: '主公有何吩咐？',
    advisors: emperorAdvisors,
    examples: emperorExamples
  },
  {
    id: 'xiyou',
    name: '西游取经团',
    description: '把烦恼当成取经路上的一关',
    icon: '🏔️',
    welcomeTitle: '施主有礼',
    welcomeDesc: '把当下烦恼当成取经路上的一关，师徒四人陪你一起过',
    inputPlaceholder: '施主有何烦恼？',
    advisors: xiyouAdvisors,
    examples: xiyouExamples
  }
];
