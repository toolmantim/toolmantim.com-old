// Legacy comments
$(function() {
  // Don't hide comments if they've linked directly to one
  if (window.location.hash.match(/#comment/)) return;
  
  $(".comments ol").hide();
  $("p.old-comments").each(function() {
    $(this).html($(this).html().replace(".", "<span> but you can <a href='javascript:void(0)'>view the " + $(".comments li").length + "&nbsp;comments left previously</a></span>."));
    $(this).find("a").click(function() {
      $(".comments ol").show();
      $(this).parent().parent().find("span").remove();
      $('html,body').animate({scrollTop: $(".comments").offset().top}, 300);
      return false;
    });
  });
});
  
// Email links
$(function() {
  $(".email").each(function() {
    var newHtml = $(this).html().replace("#{thisdomain}", "toolmantim.com");
    $(this).html(newHtml).wrap("<a href='mailto:" + newHtml + "'></a>");
  });
});
