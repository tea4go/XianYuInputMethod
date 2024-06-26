import keyboardController from '../model/KeyboardController';

@Component
@Preview
export struct MainInputPanel {
  @State mainKeyData: Array<InputButtonData> = getMainButtonGroupData();
  @State leftKeyData: Array<InputButtonData> = getLeftButtonGroupData();
  @State rightKeyData: Array<InputButtonData> = getRightButtonGroupData();
  @State bottomKeyData: Array<InputButtonData> = getBottomButtonGroupData();
  @Consume inputContent:Array<InputButtonData>
  @State layoutOptions: GridLayoutOptions = {
    regularSize: [1, 1],
    onGetRectByIndex: (index: number) => {
      if (index == 0) { // key1是“0”按键对应的index
        return [0, 0, 3, 1]
      } else if (index == 1) { // key2是“=”按键对应的index
        return [0, 1, 1, 1]
      } else if (index == 2) {
        return [0, 2, 1, 1]
      } else if (index == 3) {
        return [0, 3, 1, 1]
      } else if (index == 4) {
        return [1, 1, 1, 1]
      } else if (index == 5) {
        return [1, 2, 1, 1]
      } else if (index == 6) {
        return [1, 3, 1, 1]
      } else if (index == 7) {
        return [2, 1, 1, 1]
      } else if (index == 8) {
        return [2, 2, 1, 1]
      } else if (index == 9) {
        return [2, 3, 1, 1]
      } else if (index == 10) {
        return [0, 4, 3, 1]
      } else if (index == 11) {
        return [3, 0, 1, 5]
      } else {
        return [3, 0, 5, 1]
      }
      // ...
      // 这里需要根据具体布局返回其他item的位置
    }
  }

  build() {
    Row() {
      Grid(undefined, this.layoutOptions) {
        GridItem() {
          Column({ space: 3 }) {
            ForEach(this.leftKeyData, (item: InputButtonData, index: number) => {
              Button() {
                Text(item.name).fontSize(16).textAlign(TextAlign.Center)
              }.backgroundColor(Color.Transparent)
              .type(ButtonType.Normal)
              .width('100%').layoutWeight(1)
              .onClick(()=>{
                this.fillText(item)
              })

            }, (item: InputButtonData, index: number) => item.key)
          }.width('100%').height('100%').backgroundColor('#dde1ec')
          .borderRadius(5)
          .justifyContent(FlexAlign.SpaceAround)

        }

        ForEach(this.mainKeyData, (item: InputButtonData, index: number) => {
          GridItem() {
            Row(){
              Button() {
                Column({space: 5}) {
                  Text(item.upName).fontSize(10)
                  Text(item.name).fontSize(16)
                }
              }.backgroundColor(Color.White)
              .borderRadius(5)
              .type(ButtonType.Normal).height('100%').width('100%')
              .onClick(()=>{
                this.pushToContent(item)
              })
            }.width('100%').height('100%').padding(3).backgroundColor('#eff0f4')

          }.backgroundColor('#eff0f4')

        }, (item: InputButtonData, index: number) => item.key)


        GridItem() {
          Column({space: 4}){
            ForEach(this.rightKeyData, (item: InputButtonData, index: number) => {
              if(item.key == 'del'){
                Button() {
                  Image($r('app.media.del')).width(40).height(40)
                    .padding(5)
                }.backgroundColor('#dde3ec')
                .type(ButtonType.Normal)
                .width('100%').layoutWeight(1)
                .onClick(()=>{
                  keyboardController.deleteForward(1);
                  this.inputContent.pop()
                })
              }else if (item.key == 'zero'){
                Button() {
                  Column() {
                    Text(item.name).fontSize(18)
                  }
                }.backgroundColor('#dde3ec')
                .type(ButtonType.Normal)
                .borderRadius(5)
                .width('100%').layoutWeight(1)
                .onClick(()=>{
                  this.fillText(item)
                })
              }else{
                Button() {
                  Column() {
                    Text(item.name).fontSize(14)
                  }
                }.backgroundColor('#dde3ec')
                .type(ButtonType.Normal)
                .width('100%').layoutWeight(1)
                .onClick(()=>{
                  if(item.key == 'reInput'){
                    let length = this.getShowInputContent().length
                    keyboardController.clearText(length)
                  }
                })
              }


            }, (item: InputButtonData, index: number) => item.key)
          }.width('100%').height('100%').backgroundColor('#eff0f4')
          .borderRadius(5)
          .justifyContent(FlexAlign.SpaceAround)
        }

        // 最后一行工具行
        GridItem() {
          Row({space: 5}) {
            ForEach(this.bottomKeyData, (item: InputButtonData, index: number) => {
              // 空格
              if(item.key == 'space'){
                Button() {
                  Image($r('app.media.space')).width(40).height(40)
                }.backgroundColor(Color.White)
                .type(ButtonType.Normal)
                .borderRadius(5)
                .height('100%').layoutWeight(2.5)
                // 回车
              }else if(item.key == 'enter'){
                Button() {
                  Image($r('app.media.enter')).width(40).height(40)
                    .padding(5)
                }.backgroundColor('#dde1ec')
                .type(ButtonType.Normal)
                .borderRadius(5)
                .height('100%').layoutWeight(1)
              }else{
                Button() {
                  Text(item.name).fontSize(12)
                }.backgroundColor('#dde1ec')
                .type(ButtonType.Normal)
                .borderRadius(5)
                .height('100%').layoutWeight(1)
              }
            }, (item: InputButtonData, index: number) => item.key)
          }.width('100%')
          .height('100%')
          .backgroundColor(Color.Transparent).justifyContent(FlexAlign.SpaceBetween)
        }.margin({top: 2})

      }.rowsGap(5)
      .columnsGap(1)
      .columnsTemplate('1fr 1.5fr 1.5fr 1.5fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr')
      .backgroundColor('#eff0f4')
    }.width('100%').layoutWeight(1).backgroundColor(Color.Transparent)
    .padding({left: 16, right: 16, top: 2, bottom: 4})
  }

  /**
   * 点击按键之后的事件
   * @param inputData
   */
  pushToContent(inputData:InputButtonData){
    this.inputContent.push(inputData)
    if(inputData.fillStr){
      // 设置输入框里面的预上屏幕文本
      let previewText = this.getShowInputContent()
      // keyboardController.setPreviewText(previewText)
    }
  }

  /**
   * 填充文字
   * @param inputData
   */
  fillText(inputData:InputButtonData){
    if(inputData.fillStr){
      keyboardController.insertText(inputData.fillStr)
    }
  }

  getShowInputContent():string{
    let showText:string = ""
    this.inputContent.forEach((value, index)=>{
      showText+=value.name.charAt(0)
    })
    return showText
  }
}

export class InputButtonData {
  // 按钮上方小字
  upName: string = '';
  // 按钮显示名字
  name: string = ''
  // 按钮主键
  key: string = ''
  // 输入的字符
  fillStr:string|null = null

  constructor(upName: string, name: string, key: string, fillStr?:string) {
    this.upName = upName;
    this.name = name;
    this.key = key;
    if(fillStr){
      this.fillStr = fillStr
    }
  }
}

/**
 * 获取左边按钮组
 * @returns
 */
export function getLeftButtonGroupData(): Array<InputButtonData> {
  let array = new Array<InputButtonData>();
  array.push(new InputButtonData('', ',', ',', ","))
  array.push(new InputButtonData('', '。', ' 。', '。'))
  array.push(new InputButtonData('', '@', 'at', '@'))
  array.push(new InputButtonData('', '?', '?', '？'))
  return array
}

/**
 * 获取中间的按钮组
 * @returns
 */
export function getMainButtonGroupData(): Array<InputButtonData> {
  let array = new Array<InputButtonData>();
  array.push(new InputButtonData('1', '分词', 'split', '‘'))
  array.push(new InputButtonData('2', 'ABC', 'abc', 'abc'))
  array.push(new InputButtonData('3', 'DEF', 'def', 'def'))
  array.push(new InputButtonData('4', 'GHI', 'qhi', 'qhi'))
  array.push(new InputButtonData('5', 'JKL', 'jkl', 'jkl'))
  array.push(new InputButtonData('6', 'MNO', 'mno', 'mno'))
  array.push(new InputButtonData('7', 'PQRS', 'pqrs', 'pqrs'))
  array.push(new InputButtonData('8', 'TUV', 'tuv', 'tuv'))
  array.push(new InputButtonData('9', 'WXYZ', 'wxyz', 'wxyz'))
  return array
}

export function getRightButtonGroupData(): Array<InputButtonData> {
  let array = new Array<InputButtonData>();
  array.push(new InputButtonData('', '删除', 'del'))
  array.push(new InputButtonData('', '重输', 'reInput'))
  array.push(new InputButtonData('', '0', 'zero', '0'))
  return array
}

/**
 * 获取下方的按钮数据
 */
export function getBottomButtonGroupData(): Array<InputButtonData> {
  let array = new Array<InputButtonData>();
  array.push(new InputButtonData('', '符', 'fuhao'))
  array.push(new InputButtonData('', '123', 'number'))
  array.push(new InputButtonData('', '___', 'space'))
  array.push(new InputButtonData('', '中/英', 'chineseOrEnglish'))
  array.push(new InputButtonData('', '_|', 'enter'))
  return array
}