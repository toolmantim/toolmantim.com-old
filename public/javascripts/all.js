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

// Project image galleries
$(function() {
  $("body.projects").addClass("projects-js");
  
  $("body.projects ol.projects li ul.images").each(function() {
    var imagesContainer = $(this);
    
    if (imagesContainer.find("img").length <= 1) return;
    
    imagesContainer.find("img").hide();
    
    var navigator = $("<ul class='image-navigator' style='z-index:2'></ul>");
    imagesContainer.find("img").each(function(i) {
      var image = $(this);
      var selector = $("<li><a href='javascript:void(0)'><span></span>" + image.attr("alt") + "</a></li>");
      selector.find("a").attr("title", image.attr("alt")).click(function() {
        var oldImage = navigator.data("currentImage");
        // Already active?
        if (oldImage == image) {
          return;
        } else {
          navigator.data("currentImage", image);
          // Toggle navigator dots
          navigator.find("a").removeClass("active");
          $(this).addClass("active");
          // Swap images
          if (oldImage) oldImage.css({"z-index":1});
          image.css({"z-index":0}).show();
          if (oldImage) oldImage.fadeOut(500);
        }
      });
      navigator.append(selector);
    })
    
    navigator.find("a:first").click();
    
    navigator.css({"display":"none"});
    imagesContainer.parent().append(navigator);
    navigator.fadeIn(1000);
  });
});
