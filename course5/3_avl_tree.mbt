///|
enum AVLTree {
  Empty
  /// data, left tree, right tree, height 数据、左子树、右子树、高度
  Node(Int, AVLTree, AVLTree, Int)
} derive(Show)

///|
fn height(tree : AVLTree) -> Int {
  match tree {
    Empty => -1
    Node(_, _, _, height) => height
  }
}

///| construct a balanced tree and maintain the height 构建平衡树；高度由构建函数维护
fn construct(left : AVLTree, root : Int, right : AVLTree) -> AVLTree {
  fn max(i, j) {
    if i <= j {
      j
    } else {
      i
    }
  }

  Node(root, left, right, max(height(left), height(right)) + 1)
}

///|
fn balance(left : AVLTree, value : Int, right : AVLTree) -> AVLTree {
  // test if it is balanced 判断是否不平衡
  if height(left) > height(right) + 1 {
    let z = value
    guard left is Node(y, left_l, left_r, _)
    //                     z
    //                 /     \
    //             y          tree
    //         /     \
    //      x          tree
    //    /   \
    //  tree  tree
    if height(left_l) >= height(left_r) {
      construct(left_l, y, construct(left_r, z, right))
      //                  z
      //            /        \
      //       x               tree
      //    /     \
      //  tree     y
      //         /   \
      //        tree tree
    } else {
      guard left_r is Node(x, left_right_l, left_right_r, _)
      construct(
        construct(left_l, y, left_right_l),
        x,
        construct(left_right_r, z, right),
      )
    }
  } else if height(right) > height(left) + 1 {
    let z = value
    guard right is Node(y, right_l, right_r, _)
    if height(right_l) <= height(right_r) {
      construct(construct(left, z, right_l), y, right_r)
    } else {
      guard right_l is Node(x, right_left_l, right_right_r, _)
      construct(
        construct(left, z, right_left_l),
        x,
        construct(right_right_r, y, right_r),
      )
    }
  } else {
    construct(left, value, right)
  }
}

///| Insert an element 插入元素
fn insert(tree : AVLTree, value : Int) -> AVLTree {
  match tree {
    Empty => Node(value, Empty, Empty, 0)
    Node(v, left, right, _) =>
      if value == v {
        tree
      } else if value < v {
        balance(insert(left, value), v, right)
      } else {
        balance(left, v, insert(right, value))
      }
  }
}

///| Remove the largest element in the left tree 删除左子树最大元素
fn remove_largest(tree : AVLTree) -> (AVLTree, Int) {
  match tree {
    Empty => abort("Impossible")
    Node(v, left, Empty, _) => (left, v)
    Node(v, left, right, _) => {
      let (newRight, value) = remove_largest(right)
      (balance(left, v, newRight), value)
    }
  }
}

///| Remove an element 删除元素
fn remove(tree : AVLTree, value : Int) -> AVLTree {
  match tree {
    Empty => Empty
    Node(root, left, right, _) =>
      if value < root {
        balance(remove(left, value), root, right)
      } else if value > root {
        balance(left, root, remove(right, value))
      } else {
        match (left, right) {
          (Empty, Empty) => Empty
          (left, Empty) => left
          (Empty, right) => right
          (left, right) => {
            let (newLeft, newRoot) = remove_largest(left)
            balance(newLeft, newRoot, right)
          }
        }
      }
  }
}

///| Depth first search 深度优先遍历查找
fn dfs_search(target : Int, tree : AVLTree) -> Bool {
  match tree {
    Empty => false
    Node(value, left, right, _) =>
      value == target || dfs_search(target, left) || dfs_search(target, right)
  }
}

///| Breadth first search 广度优先遍历查找
fn bfs_search(target : Int, queue : Queue[AVLTree]) -> Bool {
  match peek(queue) {
    None => false
    Some(v) =>
      match v {
        Empty => bfs_search(target, dequeue(queue))
        Node(value, left, right, _) =>
          value == target ||
          bfs_search(target, enqueue(enqueue(dequeue(queue), left), right))
      }
  }
}

///| Depth first search and print all elements 深度优先遍历并输出
fn dfs_print(tree : AVLTree) -> String {
  match tree {
    Empty => ""
    Node(value, left, right, _) => {
      let value_str = value.to_string()
      let left_str = dfs_print(left)
      let right_str = dfs_print(right)
      left_str + value_str + " " + right_str
    }
  }
}

///| Breadth first search and print all elements 广度优先遍历并输出
fn bfs_print(queue : Queue[AVLTree]) -> String {
  match peek(queue) {
    None => ""
    Some(v) =>
      match v {
        Empty => bfs_print(dequeue(queue))
        Node(value, left, right, _) =>
          value.to_string() +
          " " +
          bfs_print(enqueue(enqueue(dequeue(queue), left), right))
      }
  }
}

///|
test {
  let tree = [0, 1, 2, 3, 4, 5, 6, 7, 8].fold(init=AVLTree::Empty, insert)
  tree |> dfs_print |> inspect(content="0 1 2 3 4 5 6 7 8 ")
  from_list(Cons(tree, Nil))
  |> bfs_print
  |> inspect(content="3 1 5 0 2 4 7 6 8 ")
  let new_tree = remove(tree, 3)
  new_tree |> dfs_print |> inspect(content="0 1 2 4 5 6 7 8 ")
  from_list(Cons(new_tree, Nil))
  |> bfs_print
  |> inspect(content="2 1 5 0 4 7 6 8 ")
  let new_tree = remove(tree, 1)
  new_tree |> dfs_print |> inspect(content="0 2 3 4 5 6 7 8 ")
  from_list(Cons(new_tree, Nil))
  |> bfs_print
  |> inspect(content="3 0 5 2 4 7 6 8 ")
  assert_true(dfs_search(3, tree))
  assert_true(bfs_search(3, enqueue(from_list(Nil), tree)))
  new_tree
  |> inspect(
    content="Node(3, Node(0, Empty, Node(2, Empty, Empty, 0), 1), Node(5, Node(4, Empty, Empty, 0), Node(7, Node(6, Empty, Empty, 0), Node(8, Empty, Empty, 0), 1), 2), 3)",
  )
}

// ----- Utils 工具 -----

///|
fn[A, B] fold_left(list : List[A], f : (B, A) -> B, b : B) -> B {
  match list {
    Nil => b
    Cons(hd, tl) => fold_left(tl, f, f(b, hd))
  }
}

// ----- Queue 队列 -----

///|
struct Queue[T] {
  front : List[T]
  back : List[T]
}

///| `Queue::default[T]()`
///
/// Create empty queue 创建空队列
fn[T] Queue::default() -> Queue[T] {
  { front: Nil, back: Nil }
}

///| `from_list[T](front: List[T])`
///
/// Create queue from list 从列表创建队列
fn[T] from_list(front : List[T]) -> Queue[T] {
  { front, back: Nil }
}

///| `list_rev[T](xs: List[T])`
///
/// Reverse a list with tail recursion 基于尾递归的列表反转
fn[T] list_rev(xs : List[T]) -> List[T] {
  fn go(acc, xs : List[T]) {
    match xs {
      Nil => acc
      Cons(x, rest) => go((Cons(x, acc) : List[T]), rest)
    }
  }

  go(Nil, xs)
}

///| `norm[T](q: Queue[T])`
///
/// Feed `back` into `front` so that `front` always have something 反转队列结构；确保列表头始终有元素
fn[T] norm(q : Queue[T]) -> Queue[T] {
  match q {
    { front: Nil, back: b } => { front: list_rev(b), back: Nil }
    q => q
  }
}

///| `enqueue[T](q: Queue[T], x: T)`
///
/// Add an element to the end of the queue 向队尾添加一个元素
fn[T] enqueue(q : Queue[T], x : T) -> Queue[T] {
  match q {
    { front: f, back: b } => norm({ front: f, back: Cons(x, b) })
  }
}

///| `peek[T](q: Queue[T])`
///
/// Remove the first element from the queue 取出队列中第一个元素
fn[T] peek(q : Queue[T]) -> T? {
  match q {
    { front: Nil, back: _ } => None
    { front: Cons(x, _), back: _ } => Some(x)
  }
}

///| `dequeue[T](q: Queue[T])`
///
/// The queue after an element is removed, returns itself if it's empty 取出一个元素后的队列；如果已经为空，则返回本身
fn[T] dequeue(q : Queue[T]) -> Queue[T] {
  match q {
    { front: Nil, back: _ } => q
    { front: Cons(_, f), back: b } => norm({ front: f, back: b })
  }
}

///|
enum List[T] {
  Nil
  Cons(T, List[T])
}
