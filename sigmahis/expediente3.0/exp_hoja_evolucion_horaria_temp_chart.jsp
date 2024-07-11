<%//@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String code = request.getParameter("code");

if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (code == null) code = "";

SQLMgr.setConnection(ConMgr);
CommonDataObject cdo = SQLMgr.getData("select ctrl_7am,ctrl_8am,  ctrl_9am,  ctrl_10am,  ctrl_11am,  ctrl_12pm,  ctrl_1pm,  ctrl_2pm,  ctrl_3pm,  ctrl_4pm,  ctrl_5pm,  ctrl_6pm,  ctrl_7pm,  ctrl_8pm,  ctrl_9pm,  ctrl_10pm,  ctrl_11pm,  ctrl_12am,  ctrl_1am,  ctrl_2am,  ctrl_3am,  ctrl_4am,  ctrl_5am,  ctrl_6am from tbl_sal_ctrl_uci_paciente_det where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo_param = 13 and codigo_hdr = "+code);
if (cdo == null) cdo = new CommonDataObject();
%>
<!DOCTYPE html>
<html lang="en">   
<head>
<meta charset="utf-8">
<script src="../js/Chart.js"></script>
<script>
    var ctx = document.getElementById("chartT").getContext("2d");
       
    var data = {
        labels: ["7am", "8am", "9am", "10am", "11am", "12pm", "1pm","2pm","3pm","4pm","5pm","6pm","7pm","8pm","9pm","10pm","11pm","12am","1am","2am","3am","4am","5am","6am"],
        datasets: [
        {
            label: "Temperaturas",
            fill: false,
            lineTension: 0.1,
            backgroundColor: "rgba(75,192,192,0.4)",
            borderColor: "rgba(75,192,192,1)",
            borderCapStyle: 'butt',
            borderDash: [],
            borderDashOffset: 0.0,
            borderJoinStyle: 'miter',
            pointBorderColor: "rgba(75,192,192,1)",
            pointBackgroundColor: "#fff",
            pointBorderWidth: 1,
            pointHoverRadius: 10,
            pointHoverBackgroundColor: "rgba(75,192,192,1)",
            pointHoverBorderColor: "rgba(220,220,220,1)",
            pointHoverBorderWidth: 2,
            pointRadius: 5,
            pointHitRadius: 10,
            data: [<%=cdo.getColValue("ctrl_7am","0")%>,<%=cdo.getColValue("ctrl_8am","0")%>,<%=cdo.getColValue("ctrl_9am","0")%>,<%=cdo.getColValue("ctrl_10am","0")%>,<%=cdo.getColValue("ctrl_11am","0")%>,<%=cdo.getColValue("ctrl_12pm","0")%>,<%=cdo.getColValue("ctrl_1pm","0")%>,<%=cdo.getColValue("ctrl_2pm","0")%>,<%=cdo.getColValue("ctrl_3pm","0")%>,<%=cdo.getColValue("ctrl_4pm","0")%>,<%=cdo.getColValue("ctrl_5pm","0")%>,<%=cdo.getColValue("ctrl_6pm","0")%>,<%=cdo.getColValue("ctrl_7pm","0")%>,<%=cdo.getColValue("ctrl_8pm","0")%>,<%=cdo.getColValue("ctrl_9pm","0")%>,<%=cdo.getColValue("ctrl_10pm","0")%>,<%=cdo.getColValue("ctrl_11pm","0")%>,<%=cdo.getColValue("ctrl_12am","0")%>,<%=cdo.getColValue("ctrl_1am","0")%>,<%=cdo.getColValue("ctrl_2am","0")%>,<%=cdo.getColValue("ctrl_3am","0")%>,<%=cdo.getColValue("ctrl_4am","0")%>,<%=cdo.getColValue("ctrl_5am","0")%>,<%=cdo.getColValue("ctrl_6am","0")%>],
            spanGaps: false,
            showDatapoints: true,
        }
        ]
    };
        
    var options = {
        scales: {
            xAxes: [{
                display: true
            }]
        },
        hover: {animationDuration: 0},
        animation: {
            duration: 0,
            onComplete: function () {
 
                var ctx = this.chart.ctx;
                ctx.font = Chart.helpers.fontString(Chart.defaults.global.defaultFontFamily, 'normal', Chart.defaults.global.defaultFontFamily);
                ctx.textAlign = 'center';
                ctx.fillStyle = "black";
                ctx.textBaseline = 'bottom';

                this.data.datasets.forEach(function (dataset) {
                    for (var i = 0; i < dataset.data.length; i++) {
                        var model = dataset._meta[0].dataset._children[i]._model;
                        ctx.fillText(dataset.data[i], model.x, model.y - 5);
                    }
                });
            }
        }
    };
    
    var chart = new Chart(ctx,{
        type: 'line',
        data: data,
        options: options
    });
</script>
</head>
<body>
<canvas id="chartT"></canvas>
</body>
</html>