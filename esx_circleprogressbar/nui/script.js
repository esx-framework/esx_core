document.addEventListener("DOMContentLoaded", function() {
  // Adjust the progress value (0 to 100) to control the progress animation
  var progressValue = 75;
  var progressBar = document.querySelector(".progress");
  var progressClip = "rect(0, " + (progressValue / 100) * 100 + "px, 100px, 0)";
  progressBar.style.clip = progressClip;
});
