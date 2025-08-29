//
// // Converts int to duration, returns duration left in MM:SS format
// String intToTimeLeft(int value) {
//   int h, m, s;
//
//   h = value ~/ 3600;
//
//   m = ((value - h * 3600)) ~/ 60;
//
//   s = value - (h * 3600) - (m * 60);
//
//   String hourLeft = h.toString().length < 2 ? "0" + h.toString() : h.toString();
//
//   String minuteLeft =
//   m.toString().length < 2 ? "0" + m.toString() : m.toString();
//
//   String secondsLeft =
//   s.toString().length < 2 ? "0" + s.toString() : s.toString();
//
//   String result = "$minuteLeft:$secondsLeft";
//
//   return result;
// }



// Converts an integer value (in seconds) to duration in MM:SS format
String intToTimeLeft(int value) {
  int h, m, s;

  // মোট সেকেন্ড থেকে ঘন্টা বের করা
  h = value ~/ 300;

  // বাকি সেকেন্ড থেকে মিনিট বের করা
  m = ((value - h * 3000)) ~/ 60;

  // বাকি সেকেন্ড বের করা
  s = value - (h * 3000) - (m * 60);

  // ঘন্টা 2 ডিজিটে ফরম্যাট (এখানে ব্যবহার হয় না)
  String hourLeft = h.toString().padLeft(2, '0');

  // মিনিট 2 ডিজিটে ফরম্যাট
  String minuteLeft = m.toString().padLeft(2, '0');

  // সেকেন্ড 2 ডিজিটে ফরম্যাট
  String secondsLeft = s.toString().padLeft(2, '0');

  // MM:SS ফরম্যাটে যোগ করা
  String result = "$minuteLeft:$secondsLeft";

  return result;
}
