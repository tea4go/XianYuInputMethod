import { getAllPinyinList } from './PinyinListData';

/**
 b ba bo bai bei bao ban ben bang beng bi bie biao bian bin bing bu
 p pa po pai pao pou pan pen pei pang peng pi pie piao pian pin ping pu
 m ma mo me mai mao mou man men mei mang meng mi mie miao miu mian min ming mu
 f fa fo fei fou fan fen fang feng fu
 d da de dai dei dao dou dan dang den deng di die diao diu dian ding dong du duan dun dui duo
 t ta te tai tao tou tan tang teng ti tie tiao tian ting tong tu tuan tun tui tuo
 n na nai nei nao ne nen nan nang neng ni nie niao niu nian nin niang ning nong nou nu nuan nun nuo nü nüe
 l la le lo lai lei lao lou lan lang leng li lia lie liao liu lian lin liang ling long lu luo lou luan lun lü lüe
 g ga ge gai gei gao gou gan gen gang geng gong gu gua guai guan guang gui guo
 k ka ke kai kao kou kan ken kang keng kong ku kua kuai kuan kuang kui kun kuo
 h ha he hai han hei hao hou hen hang heng hong hu hua huai huan hui huo hun huang
 j ji jia jie jiao jiu jian jin jiang jing jiong ju juan jun jue
 q qi qia qie qiao qiu qian qin qiang qing qiong qu quan qun que
 x xi xia xie xiao xiu xian xin xiang xing xiong xu xuan xun xue
 zh zha zhe zhi zhai zhao zhou zhan zhen zhang zheng zhong zhu zhua zhuai zhuan zhuang zhun zhui zhuo
 ch cha che chi chai chao chou chan chen chang cheng chong chu chua chuai chuan chuang chun chui chuo
 sh sha she shi shai shao shou shan shen shang sheng shu shua shuai shuan shuang shun shui shuo
 r re ri rao rou ran ren rang reng rong ru ruan run ruo
 z za ze zi zai zao zan zou zang zei zen zeng zong zu zuan zun zui zuo
 c ca ce ci cai cao cou can cen cang ceng cong cu cuan cun cui cuo
 s sa se si sai sao sou san sen sang seng song su suan sun sui suo
 y ya yao you yan yang yu ye yue yuan yi yin yun ying yo yong
 w wa wo wai wei wan wen wang weng wu
 *
 */
class TrieNode {
  children: Map<string, TrieNode>;
  isEndOfWord: boolean;

  constructor() {
    this.children = new Map();
    this.isEndOfWord = false;
  }
}

class Trie {
  root: TrieNode;

  constructor() {
    this.root = new TrieNode();
  }

  // 向字典树中添加单词
  addWord(word: string) {
    let node = this.root;
    for (const char of word) {
      if (!node.children.has(char)) {
        node.children.set(char, new TrieNode());
      }
      node = node.children.get(char)!;
    }
    node.isEndOfWord = true;
  }

  // 查询给定前缀后可能的单词
  getFollowingWords(prefix: string): string[] {
    let node = this.root;
    for (const char of prefix) {
      if (!node.children.has(char)) return [];
      node = node.children.get(char)!;
    }

    const words: string[] = [];
    this._collectWords(node, prefix, words);
    return words;
  }

  // 辅助函数：递归收集以node为根的路径上的所有单词
  private _collectWords(node: TrieNode, prefix: string, words: string[]): void {
    if (node.isEndOfWord) {
      words.push(prefix);
    }


    node.children.forEach((child, char) => {
      this._collectWords(child, prefix + char, words);
    });
  }
}


// ... 之前的 TrieNode 和 Trie 定义保持不变 ...
interface FollowingWordsAndSegments {
  words: string[];
  segments: string[];
}

class TrieWithSegmentation extends Trie {
  // 修改查询方法以支持分词功能
  getFollowingWordsAndSegments(prefix: string): FollowingWordsAndSegments {
    let node = this.root;
    for (const char of prefix) {
      if (!node.children.has(char)) return { words: [], segments: [] };
      node = node.children.get(char)!;
    }

    const words: string[] = [];
    const segments: string[] = []; // 用于存储分词结果

    this._collectWordsAndSegments(node, prefix, words, segments, true);
    return { words, segments };
  }

  // 辅助函数：递归收集以node为根的路径上的所有单词及分词
  private _collectWordsAndSegments(node: TrieNode, prefix: string, words: string[], segments: string[], isFirstLevel = false) {
    if (isFirstLevel || node.isEndOfWord) {
      words.push(prefix);
      if (isFirstLevel) segments.push(prefix); // 首次进入或到达完整词时，记录为分词
    }

    node.children.forEach((child, char) => {
      this._collectWordsAndSegments(child, prefix + char, words, segments, false);
    });
  }
}


// 使用示例
export function trieMain() {
  const trieWithSeg = new TrieWithSegmentation();
  const pinyinList = getAllPinyinList();

  // 添加所有拼音到字典树
  pinyinList.forEach((pinyin) => {
    if(pinyin){
      trieWithSeg.addWord(pinyin)
    }
  });

  // 查询输入'ai'之后可能的拼音和分词
  const input = 'a';


  const followingWordsAndSegments = trieWithSeg.getFollowingWordsAndSegments(input);
  const possibleWords = followingWordsAndSegments.words;
  const possibleSegments = followingWordsAndSegments.segments;

  console.log(`输入 '${input}' 后可能的拼音有：`, possibleWords);
  console.log(`输入 '${input}' 后可能的分词有：`, possibleSegments);

  // 进一步查询，输入'aih'
  const furtherInput = 'ai';
  const seg = trieWithSeg.getFollowingWordsAndSegments(furtherInput);
  const furtherSegments = seg.segments;
  console.log(`继续输入 'h'，可能的分词变为：`, furtherSegments);
}