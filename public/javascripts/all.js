// CSS grid
$(function() {
  if (window.location.toString().match(/\?grid$/)) $(document.body).addClass("grid");
})

// Email links
$(function() {
  $(".email").each(function() {
    var html = $(this).html().replace("#{thisdomain}", "toolmantim.com");
    $(this).html(html).wrap("<a href='mailto:" + html + "'></a>");;
  });
  // Article feedback has subject toi
  $(".article .feedback a .email").each(function() {
    var a = $(this).parent();
    a.attr("href", a.attr("href") + "?subject=Re: " + $("title").text());
  });
});

// Github ads
$(function() {
  $(".github-ad a").click(function() {
    pageTracker._trackPageview('/outgoing/github.com');
    return true;
  });
});
