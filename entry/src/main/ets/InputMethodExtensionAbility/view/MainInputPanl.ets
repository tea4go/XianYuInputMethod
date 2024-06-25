@Component
@Preview
export struct MainInputPanel {
  @State mainKeyData: Array<InputButtonData> = getMainButtonGroupData();
  @State leftKeyData: Array<InputButtonData> = getLeftButtonGroupData();
  @State rightKeyData: Array<InputButtonData> = getRightButtonGroupData();
  @State bottomKeyData: Array<InputButtonData> = getBottomButtonGroupData();
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
                Text(item.name).fontSize(12)
              }.backgroundColor(Color.Transparent)
              .type(ButtonType.Normal)
              .width('100%').layoutWeight(1)

            }, (item: InputButtonData, index: number) => item.key)
          }.width('100%').height('100%').backgroundColor(Color.Green)
          .justifyContent(FlexAlign.SpaceAround)

        }

        ForEach(this.mainKeyData, (item: InputButtonData, index: number) => {
          GridItem() {
            Button() {
              Column() {
                Text(item.upName).fontSize(8)
                Text(item.name).fontSize(12)
              }
            }.backgroundColor(Color.Transparent)
            .type(ButtonType.Normal).height('100%').width('100%')
          }

        }, (item: InputButtonData, index: number) => item.key)


        GridItem() {
          Column(){
            ForEach(this.rightKeyData, (item: InputButtonData, index: number) => {
              Button() {
                Column() {
                  Text(item.name).fontSize(12)
                }
              }.backgroundColor(Color.Transparent)
              .width('100%').layoutWeight(1)

            }, (item: InputButtonData, index: number) => item.key)
          }.width('100%').height('100%').backgroundColor(Color.Orange)
          .justifyContent(FlexAlign.SpaceAround)
        }

        // 最后一行工具行
        GridItem() {
          Row() {
            ForEach(this.bottomKeyData, (item: InputButtonData, index: number) => {
              Button() {
                Text(item.name).fontSize(12)
              }.backgroundColor(Color.Transparent)
              .type(ButtonType.Normal)
              .height('100%').layoutWeight(1)

            }, (item: InputButtonData, index: number) => item.key)
          }.width('100%')
          .height('100%')
          .backgroundColor(Color.Yellow).justifyContent(FlexAlign.SpaceBetween)
        }

      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr')
    }.width('100%').layoutWeight(1).backgroundColor(Color.Pink)
  }
}

export class InputButtonData {
  // 按钮上方小字
  upName: string = '';
  // 按钮显示名字
  name: string = ''
  // 按钮主键
  key: string = ''

  constructor(upName: string, name: string, key: string) {
    this.upName = upName;
    this.name = name;
    this.key = key;
  }
}

/**
 * 获取左边按钮组
 * @returns
 */
export function getLeftButtonGroupData(): Array<InputButtonData> {
  let array = new Array<InputButtonData>();
  array.push(new InputButtonData('', ',', ','))
  array.push(new InputButtonData('', '。', '。'))
  array.push(new InputButtonData('', '@', 'at'))
  array.push(new InputButtonData('', '?', '?'))
  return array
}

/**
 * 获取中间的按钮组
 * @returns
 */
export function getMainButtonGroupData(): Array<InputButtonData> {
  let array = new Array<InputButtonData>();
  array.push(new InputButtonData('1', '分词', 'split'))
  array.push(new InputButtonData('2', 'ABC', 'abc'))
  array.push(new InputButtonData('3', 'DEF', 'def'))
  array.push(new InputButtonData('4', 'GHI', 'qhi'))
  array.push(new InputButtonData('5', 'JKL', 'jkl'))
  array.push(new InputButtonData('6', 'MNO', 'mno'))
  array.push(new InputButtonData('7', 'PQRS', 'pqrs'))
  array.push(new InputButtonData('8', 'TUV', 'tuv'))
  array.push(new InputButtonData('9', 'WXYZ', 'wxyz'))
  return array
}

export function getRightButtonGroupData(): Array<InputButtonData> {
  let array = new Array<InputButtonData>();
  array.push(new InputButtonData('', '删除', 'del'))
  array.push(new InputButtonData('', '重输', 'reInput'))
  array.push(new InputButtonData('', '0', 'zero'))
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