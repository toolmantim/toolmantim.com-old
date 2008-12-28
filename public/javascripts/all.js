// Email links
$(function() {
  $(".email").each(function() {
    var newHtml = $(this).html().replace("#{thisdomain}", "toolmantim.com");
    $(this).html(newHtml).wrap("<a href='mailto:" + newHtml + "'></a>");
  });
});
