import GlobalContext from '../context/GlobalContext';
import { Words } from '../data/Words'
import { ArrayList } from '@kit.ArkTS';
import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../util/Logger';

namespace WordService{

  /**
   * 通过拼音模糊查询
   * @param pageIndex
   * @param pageSize
   * @returns
   */
  export function queryByKeywordPage(keyword:string, pageIndex:number, pageSize:number):ArrayList<Words>{
    let store = GlobalContext.getContext().getWordDb()
    if(!store){
      Logger.error('store err , store is ' + store)
      return new ArrayList()
    }
    let offset = (pageIndex - 1) * pageSize;
    let likeCondition = "" + keyword + "%"
    let querySql = 'select * from words where pinyin like ? order by pinyin, frequency desc limit ? offset ?'
    let resultSet = store.querySqlSync(querySql, [likeCondition, pageSize, offset])
    let list = Words.resultSetToList(resultSet)
    return list
  }



  /**
   * 根据拼音查询
   * @param keyword
   * @returns
   */
  export function queryByKeyword(keyword:string):ArrayList<Words>{
    let store = GlobalContext.getContext().getWordDb()
    if(!store){
      Logger.error('store err , store is ' + store)
      return new ArrayList()
    }
    let querySql = 'select * from words where pinyin = ? order by pinyin, frequency'
    let resultSet = store.querySqlSync(querySql, [keyword])
    let list = Words.resultSetToList(resultSet)
    return list
  }

/**
 * 查询所有关键字开头，长度为x的数据
 * @param keyword
 * @param length
 * @returns
 */
  export function queryAllByKeywordForLike(keyword:string, length:number):ArrayList<Words>{
    let store = GlobalContext.getContext().getWordDb()
    if(!store){
      Logger.error('store err , store is ' + store)
      return new ArrayList()
    }
    let likeCondition = "" + keyword + "%"
    let querySql = 'select * from words where pinyin like ? AND LENGTH(word) = ? order by pinyin, frequency'
    let resultSet = store.querySqlSync(querySql, [likeCondition, length])
    let list = Words.resultSetToList(resultSet)
    return list
  }



  /**
   * 更新使用频率，提升下一个词语出现的排序
   * @param frequency
   * @param wordId
   */
  export function updateFrequency(frequency:number, wordId:number){
    // 修改数据
    let predicates = new relationalStore.RdbPredicates(Words.getTableName()); // 创建表'EMPLOYEE'的predicates
    predicates.equalTo('WORD_ID', wordId);
    let store = GlobalContext.getContext().getWordDb()
    const valueBucket1: relationalStore.ValuesBucket = {
      'FREQUENCY': frequency,
    };

    if (store !== undefined) {
      (store as relationalStore.RdbStore).update(valueBucket1, predicates, (err: BusinessError, rows: number) => {
        if (err) {
          console.error(`更新词语排序异常. Code:${err.code}, message:${err.message}`);
          return;
        }
      })
    }
  }

}

export default WordService