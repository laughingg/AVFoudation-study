import Foundation
import UIKit

// int 值替换
func swapTwoInts(_ a: inout Int, _ b: inout Int) {
    let temporary = a
    a = b
    b = temporary
}

var a = 12
var b = 13

print(a)
print(b)

swapTwoInts(&a, &b)

print(a)
print(b)

// string 值替换
func swapTwoSting(_ a: inout String, _ b: inout String) {
    let temporary = a
    a = b
    b = temporary
}

var aStr = "hello"
var bStr = "world!"

print(aStr)
print(bStr)

swapTwoSting(&aStr, &bStr);

print(aStr)
print(bStr)

// 泛型
/*
 * V: 占位类型名, 来代替实际类型名。
 * 占位类型名没有指明 V 必须是什么类型，但是它指明了 a 和 b 必须是同一类型 V，无论 V 代表什么类型。只有 swapTwoValues(_:_:) 函数在调用时，才能根据所传入的实际类型决定 V 所代表的类型。
 
 * <V>: 尖括号告诉 Swift 那个 V 是函数定义内的一个占位类型名，因此 Swift 不会去查找名为 V 的实际类型。(在调用的时候会去检查， V 所代表的类型都会由传入的值的类型推断出来)
 *
 *
 *  泛型参数定义： <T>, 首字母大写，驼峰命名规则。
 *      例如： Dictionary<Key, Value>, Array<Element>
 *
 *  泛型类型：
 *
 */
func swapTwoValues<V>(_ a: inout V, _ b: inout V) {
    let temporary = a
    a = b
    b = temporary
}

var a1 = 10
var b1 = 20

print(a1)
print(b1)

swapTwoValues(&a1, &b1)

print(a1)
print(b1)

var a2 = "laughing"
var b2 = "gnihgual"

print(a2)
print(b2)

swapTwoValues(&a2, &b2)

print(a2)
print(b2)



// 泛型类型
// Int 栈
struct IntStack {

    var items = [Int]()
    
    mutating func push(_ item: Int) {
        items.append(item)
    }
    
    mutating func pop() -> Int {
        return items.removeLast()
    }
}


// 泛型类型定义
struct Stack<Element> {
    
    var items = [Element]()
    
    mutating func push(_ item: Element) {
        items.append(item)
    }
    
    mutating func pop() -> Element {
        return items.removeLast()
    }
}

extension Stack {
    var topItem: Element? {
        return items.isEmpty ? nil : items[items.count - 1]
    }
}


// 类型约束语法
/*
 * 类型参数名后面放置一个类名或者协议名，并用冒号进行分隔，来定义类型约束，它们将成为类型参数列表的一部分
 */
//func someFunction<T: NSObject, U: NSObjectProtocol>(someT: T, someU: U) {
//    // 这里是泛型函数的函数体部分
//}



// 关联类型
protocol Container {
    
    // 关联类型
    associatedtype ItemType
    mutating func append(_ item: ItemType)
    var count: Int { get }
    
    // 下标
    subscript(i: Int) -> ItemType { get }
}


/*
 * associatedtype 和 typealias 是结合使用的
 */


struct Int2Stack: Container {
    // IntStack 的原始实现部分
    var items = [Int]()
    mutating func push(_ item: Int) {
        items.append(item)
    }
    mutating func pop() -> Int {
        return items.removeLast()
    }
    // Container 协议的实现部分
    // 指定关联类型的类型
    typealias ItemType = Int
    mutating func append(_ item: Int) {
        self.push(item)
    }
    var count: Int {
        return items.count
    }
    subscript(i: Int) -> Int {
        return items[i]
    }
}


// 由于 Array 已经完全的实现了协议的内容，因此可以直接遵守一个空的协议就可以来扩展一个关联类型
extension Array: Container {}

