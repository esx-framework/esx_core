$(window).ready(function () {
  window.addEventListener("message", function (event) {
    let data = event.data;

    if (data.showMenu) {
      $("#container").fadeIn();
      $("#container").data("spawnpoint", data.spawnPoint);
      $("#menu").fadeIn();

      $("#vehicle-list").html(getVehicles(data.locales, data.vehiclesList));

      // Locales
      // $(".vehicle-listing").html($(".vehicle-listing").html().replace("Model", data.locales.veh_model));
      // $(".vehicle-listing").html($(".vehicle-listing").html().replace("Plate", data.locales.veh_plate));
      // $(".vehicle-listing").html($(".vehicle-listing").html().replace("Vehicle condition", data.locales.veh_condition));
      // $(".vehicle-listing").html($(".vehicle-listing").html().replace("Action", data.locales.veh_action));

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
  });

  document.onkeyup = function (data) {
    if (data.which == 27) {
      $.post("https://esx_garage/escape", "{}");
    }
  };

  function getVehicles(locale, vehicle) {
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
        "<button class='vehicle-action unstyled-button' data-vehprops='" +
        JSON.stringify(vehicleData[i].props) +
        "'>" +
        locale.action +
        "</button>";
      html += "</div>";
    }

    return html;
  }

  $(document).on("click", "button.vehicle-action", function (event) {
    let spawnPoint = $("#container").data("spawnpoint");
    let vehicleProps = $(this).data("vehprops");
    let vehicleDamage = $(this).data("vehdamage");

    $.post(
      "https://esx_garage/spawnVehicle",
      JSON.stringify({
        vehicleProps: vehicleProps,
        spawnPoint: spawnPoint,
      })
    );
  });
});
