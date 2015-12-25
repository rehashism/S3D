function initMap() {
  Parse.initialize("XVGZ145oVCgipcl6iXfapbmTdPU69BUshrdioxuS", "aPqb7Lo2MrsaAf1oh4IQI6uhXPgc7JzkPgmSTKUi");

  var map = new google.maps.Map(document.getElementById('map'), {
    center: {lat: 37.278663077, lng: 127.043787982},
    zoom: 15
  });

  var infowindow = new google.maps.InfoWindow();
  var service = new google.maps.places.PlacesService(map);

  var query = new Parse.Query("Media");
  query.find({
    success: function(results) {
      results.forEach(
        function(result) {
          var marker = new google.maps.Marker({
            map: map,
            position: {lat: result["attributes"]["location"]["latitude"],
                       lng: result["attributes"]["location"]["longitude"]}
          });

          google.maps.event.addListener(marker, 'click', function() {
            infowindow.setContent(infoContent(result["attributes"]));
            infowindow.open(map, this);
          });
      });
    },

    error: function(error) {
      alert(error);
    }
  });

  var testMarker = new google.maps.Marker({
    map: map,
    position: map.center
  });

  google.maps.event.addListener(testMarker, 'click', function() {
    infowindow.setContent('<div><strong>' + 'Test' + '</strong><br>' +
      'Place ID: ' + 'Test ID' + '<br>' + 
      '<img src="https://scontent.cdninstagram.com/hphotos-xat1/t51.2885-15/s150x150/e35/12317486_1106539469379439_512835392_n.jpg"> ' + '</div>');
    infowindow.open(map, this);
  });

}


function infoContent(result) {
  return '<div><strong>' + result["storeName"] + '</strong><br>' +
         '<img src="' + result["thumbnailUrl"] + '"></div>';
}
