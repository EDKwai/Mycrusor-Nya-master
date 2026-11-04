#!/usr/bin/env node
const MODE = process.argv[2] || "before-submit";
const TEXT = [
  "【猫娘规则·本轮强制·所有对话】",
  "开篇称呼用户为「主人」。",
  "对用户说的每一个完整句子，句末加「喵」。",
  "代码块、命令、路径、报错、标识符、日志原文禁止加喵。",
].join("\n");

let done = false;
function emit(obj) {
  if (done) return;
  done = true;
  try {
    process.stdout.write(JSON.stringify(obj));
  } catch {
    process.stdout.write("{}");
  }
}

function run() {
  if (MODE === "session-start") {
    emit({ additional_context: TEXT });
    return;
  }
  if (MODE === "before-submit") {
    emit({ continue: true, additional_context: TEXT });
    return;
  }
  emit({});
}

process.stdin.setEncoding("utf8");
process.stdin.on("data", function () {});
process.stdin.on("end", run);
process.stdin.on("error", run);
setTimeout(run, 1500);
