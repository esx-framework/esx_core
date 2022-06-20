$(window).ready(function () {
  window.addEventListener("message", function (event) {
    let data = event.data;

    if (data.showMenu) {
      $("#container").fadeIn();
      $("#menu").fadeIn();

      if (data.type === 'impound') {
        $('#header ul').hide();
      } else {
        $('#header ul').show();
      }


      if (data.vehiclesList != undefined) {
        $("#container").data("spawnpoint", data.spawnPoint);
        if (data.poundCost) $("#container").data("poundcost", data.poundCost);

        if (data.poundCost != undefined) {
          $(".content .vehicle-list").html(getVehicles(data.locales, data.vehiclesList, data.poundCost));
        } else {
          $(".content .vehicle-list").html(getVehicles(data.locales, data.vehiclesList));
        }

        $('.content h2').hide();
      } else {
        $('.content h2').show();
        $('.content .vehicle-list').empty();
      }

      if (data.vehiclesImpoundedList != undefined) {
        $(".impounded_content").data("poundName", data.poundName);
        $(".impounded_content").data("poundSpawnPoint", data.poundSpawnPoint);

        if (data.poundCost) $("#container").data("poundcost", data.poundCost);

        $(".impounded_content .vehicle-list").html(getImpoundedVehicles(data.locales, data.vehiclesImpoundedList));
        $('.impounded_content h2').hide();
      } else {
        $('.impounded_content h2').show();
        $('.impounded_content .vehicle-list').empty();
      }

      // Locales

      // needs a rework
      // $(".content h2").html(function (i, text) {
      //   return text.replace("No vehicle in this garage.", data.locales.no_veh_parking);
      // });

      // $(".impounded_content h2").html(function (i, text) {
      //   return text.replace("No vehicle impounded.", data.locales.no_veh_impounded);
      // });

      $(".vehicle-listing").html(function (i, text) {
        return text.replace("Model", data.locales.veh_model);
      });
      $(".vehicle-listing").html(function (i, text) {
        return text.replace("Plate", data.locales.veh_plate);
      });
      $(".vehicle-listing").html(function (i, text) {
        return text.replace("Condition", data.locales.veh_condition);
      });
    } else if (data.hideAll) {
      $("#container").fadeOut();
    }
  });

  $("#container").hide();

  $(".close").click(function (event) {
    $("#container").hide();
    $.post("https://esx_garage/escape", "{}");

    $(".impounded_content").hide();
    $(".content").show();
    $('li[data-page="garage"]').addClass("selected")
    $('li[data-page="impounded"]').removeClass("selected")
  });

  document.onkeyup = function (data) {
    if (data.which == 27) {
      $.post("https://esx_garage/escape", "{}");

      $(".impounded_content").hide();
      $(".content").show();
      $('li[data-page="garage"]').addClass("selected")
      $('li[data-page="impounded"]').removeClass("selected")
    }
  };

function getVehicles(locale, vehicle, amount = null) {
  let html = "";
  let vehicleData = JSON.parse(vehicle);
  let bodyHealth = 1000;
  let engineHealth = 1000;
  let tankHealth = 1000;
  let vehicleDamagePercent = "";

  for (let i = 0; i < vehicleData.length; i++) {
    bodyHealth = (vehicleData[i].props.bodyHealth / 1000) * 100;
    engineHealth = (vehicleData[i].props.engineHealth / 1000) * 100;
    tankHealth = (vehicleData[i].props.tankHealth / 1000) * 100;

    vehicleDamagePercent =
      Math.round(((bodyHealth + engineHealth + tankHealth) / 300) * 100) +
      "%";

    html += "<div class='vehicle-listing'>";
    html += "<div>Model: <strong>" + vehicleData[i].model + "</strong></div>";
    html += "<div>Plate: <strong>" + vehicleData[i].plate + "</strong></div>";
    html +=
      "<div>Condition: <strong>" + vehicleDamagePercent + "</strong></div>";
    html +=
      "<button data-button='spawn' class='vehicle-action unstyled-button' data-vehprops='" +
      JSON.stringify(vehicleData[i].props) +
      "'>" +
      locale.action + (amount ? " ($" + amount + ")" : "") +
      "</button>";
    html += "</div>";
  }

  return html;
}

function getImpoundedVehicles(locale, vehicle) {
  let html = "";
  let vehicleData = JSON.parse(vehicle);
  let bodyHealth = 1000;
  let engineHealth = 1000;
  let tankHealth = 1000;
  let vehicleDamagePercent = "";

  for (let i = 0; i < vehicleData.length; i++) {
    bodyHealth = (vehicleData[i].props.bodyHealth / 1000) * 100;
    engineHealth = (vehicleData[i].props.engineHealth / 1000) * 100;
    tankHealth = (vehicleData[i].props.tankHealth / 1000) * 100;

    vehicleDamagePercent =
      Math.round(((bodyHealth + engineHealth + tankHealth) / 300) * 100) +
      "%";

    html += "<div class='vehicle-listing'>";
    html += "<div>Model: <strong>" + vehicleData[i].model + "</strong></div>";
    html += "<div>Plate: <strong>" + vehicleData[i].plate + "</strong></div>";
    html +=
      "<div>Condition: <strong>" + vehicleDamagePercent + "</strong></div>";
    html +=
      "<button data-button='impounded' class='vehicle-action red unstyled-button' data-vehprops='" +
      JSON.stringify(vehicleData[i].props) +
      "'>" +
      locale.impound_action +
      "</button>";
    html += "</div>";
  }

  return html;
}


  $('li[data-page="garage"]').click(function(event) {
    $(".impounded_content").hide();
    $(".content").show();
    $('li[data-page="garage"]').addClass("selected")
    $('li[data-page="impounded"]').removeClass("selected")
  });

  $('li[data-page="impounded"]').click(function(event) {
    $(".content").hide();
    $(".impounded_content").show();
    $('li[data-page="impounded"]').addClass("selected")
    $('li[data-page="garage"]').removeClass("selected")
  });

  $(document).on("click", "button[data-button='spawn'].vehicle-action", function (event) {
    let spawnPoint    = $("#container").data("spawnpoint");
    let poundCost     = $("#container").data("poundcost");
    let vehicleProps  = $(this).data("vehprops");

    // prevent empty cost
    if (poundCost === undefined) poundCost = 0;    

    $.post(
      "https://esx_garage/spawnVehicle",
      JSON.stringify({
        vehicleProps: vehicleProps,
        spawnPoint: spawnPoint,
        exitVehicleCost: poundCost
      })
    );

    $(".impounded_content").hide();
    $(".content").show();
    $('li[data-page="garage"]').addClass("selected")
    $('li[data-page="impounded"]').removeClass("selected")
  });

  $(document).on("click", "button[data-button='impounded'].vehicle-action", function (event) {

    let vehicleProps  = $(this).data("vehprops");
    let poundName = $(".impounded_content").data("poundName");
    let poundSpawnPoint = $(".impounded_content").data("poundSpawnPoint");
    $.post(
      "https://esx_garage/impound",
      JSON.stringify({
        vehicleProps: vehicleProps,
        poundName: poundName,
        poundSpawnPoint: poundSpawnPoint
      })
    );

    $(".impounded_content").hide();
    $(".content").show();
    $('li[data-page="garage"]').addClass("selected")
    $('li[data-page="impounded"]').removeClass("selected")
  });
});
