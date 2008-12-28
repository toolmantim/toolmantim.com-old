// CSS grid
$(function() {
  if (window.location.toString().match(/\?grid$/)) $(document.body).addClass("grid");
})

// Email links
$(function() {
  $(".email").each(function() {
    var newHtml = $(this).html().replace("#{thisdomain}", "toolmantim.com");
    $(this).html(newHtml).wrap("<a href='mailto:" + newHtml + "'></a>");
  });
});
