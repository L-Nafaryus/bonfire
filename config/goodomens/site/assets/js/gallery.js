var baseUrl = "/gallery/images/";
var pictureIndex = 0;
var pictures = [];

function getFiles() {
	$.ajax(baseUrl).success(function(data) {
		pictures = [];
		var lastPicture = "";
		$(data).find("a[href]").each(function() {
			var href = $(this).attr('href');
			if (href.indexOf('.jpg') > 0 || href.indexOf('.jpeg') > 0) {
				if (href != lastPicture) {
					pictures.push(href);
					lastPicture = href;
				}
			}
		});
		console.log("gallery: " + pictures.length + " pictures loaded");
		changePicture(0);
	});
}

function changePicture(indexOffset) {
	pictureIndex += indexOffset;
	if (pictureIndex >= pictures.length) {
		pictureIndex = 0;
	} else if (pictureIndex < 0) {
		pictureIndex = pictures.length - 1;
	}
    if (pictures.length != 0) {
        $('#viewer').attr('src', baseUrl + pictures[pictureIndex]);
        $('#info').text((pictureIndex + 1) + "/" + pictures.length);
    }
}
