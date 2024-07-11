<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="issi.admin.ConnectionMgr"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.util.ArrayList"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2"/>
<%
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String fp = request.getParameter("fp");
String type = request.getParameter("type");
String owner = request.getParameter("owner");
String ckSample = request.getParameter("ckSample");

if (fp == null) fp = "";
if (type == null) type = "EMP";
if (owner == null) owner = "";
if (ckSample == null) ckSample = "1";

String dir = ".";

if (request.getMethod().equalsIgnoreCase("GET")){
    if (!CmnMgr.isValidFpType(type)) throw new Exception("El Tipo de Huella Dactilar no está habilitada. Por favor consulte con su administrador!");
    if (type.trim().equals("")) throw new Exception("Tipo de Captura inválida!");

    String mode = request.getParameter("mode");
    boolean viewMode = false;
    if (mode == null) mode = "add";
    if (mode.equalsIgnoreCase("view")) viewMode = true;

    //
    StringBuffer sbComm = new StringBuffer();

    CommonDataObject cdo = SQLMgr.getData("select nvl(get_sec_comp_param(0,'SEC_APP_SERV_COMM_HOST'),' ') as appServCommHost from dual");
    //CommonDataObject cdo = null;
    if (cdo == null) {
        cdo = new CommonDataObject();
        cdo.addColValue("appServCommHost","");
    }

    if (cdo.getColValue("appServCommHost").trim().equals("") || cdo.getColValue("appServCommHost").equalsIgnoreCase("-")) {

        sbComm.append(request.getRequestURL().toString().replaceAll(request.getRequestURI(),""));
        sbComm.append(request.getContextPath());
        sbComm.append("/appServComm");

    } else sbComm.append(cdo.getColValue("appServCommHost"));
    cdo = null;
    issi.admin.StringEncrypter se = new issi.admin.StringEncrypter();
%>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <meta http-equiv="x-ua-compatible" content="IE=11">

    <title>CellByte BIO</title>

    <link href="<%=dir%>/css/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=dir%>/css/employee_control.css" rel="stylesheet">
	
    
    <style>
		.mr-50{margin-right: 50px}
		.btn-primary.focus, .btn-primary:focus {background-color: orange;}
		.bg-orange {
			background-color: orange;
		}
		
		#calc-contain{
		  position: relative;
		  width: 400px;
		  border: 2px solid black;
		  border-radius: 12px;
		  margin: 0px auto;
		  padding: 20px 20px 100px 20px;
		}
		input[type=button] {
		  background: #F9A03F;
		  width: 20%;
		  font-size: 20px;
		  font-weight: 900;
		  border-radius: 7px;
		  margin-left: 13px;
		  margin-top: 10px;
		}
		input[type=button]:active {
		  background-color: #F9A03F;
		  box-shadow: 0 5px #666;
		  transform: translateY(4px);
		}
		input[type=button]:hover {
		  background-color: #3498DB;
		  color: white;
		}
    </style>
  </head>

  <body>

    <div class="site-wrapper">

      <div class="site-wrapper-inner">

        <div class="cover-container" id="owner-selector">
            <div class="inner cover"></div>
        </div>
        
        <table class="table">
            
            <tr style="text-align: left">
              <td colspan="2">
                <button data-type="1" class="btn btn-primary mr-50 btn-lg action-type">Entrada</button>
                <button data-type="2" class="btn btn-primary mr-50 btn-lg action-type">Salida Almuerzo</button>
                <button data-type="3" class="btn btn-primary mr-50 btn-lg action-type">Entrada Almuerzo</button>
                <button data-type="4" class="btn btn-primary mr-50 btn-lg action-type">Salida</button>
                <button data-type="5" class="btn btn-primary mr-50 btn-lg action-type">Validar</button>
              </td>
            </tr>
			
            <tr>
                <td width="70%">
                    <div id="fpHolder">
                        <object name="fpApp" id="fpApp" type="application/x-java-applet" width="100%" height="500">
                            <param name="codebase" value="<%=request.getContextPath()%>/applet/"/>
                            <param name="archive" value="issibio.jar"/>
                            <param name="code" value="issi.applet.Capture"/>
                            <param name="scriptable" value="true"/>
                            <param name="mayscript" value="true"/>
                            <param name="cache_option" value="yes"/>
                            <param name="dLvl" value="6"/>
                            <param name="onDataAcquired" value="dataAcquiredHandler"/>
                            <param name="communicator" value="<%=sbComm%>"/>
                            <param name="sessionId" value="<%=session.getId()%>"/>
                            <param name="suser" value=""/>
                            <param name="sip" value="<%=se.encrypt(request.getRemoteAddr())%>"/>
                            <param name="type" value="<%=type%>"/>
                            <param name="owner" value="<%=owner%>"/>
                            <param name="ckSample" value="<%=ckSample%>"/>
                            <br/><a href="<%=request.getContextPath()%>/applet/jre-6u30-windows-i586.exe">Descargar Java Plug-in</a>
                        </object>
                    </div> <!-- fpHolder -->
                </td>
                
                <td>
                    <%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
                    <%=fb.formStart(true)%>
                    
                    <div class="inner cover" style="text-align: left">
					
						<table id="tbl-alt" style="display:none; margin-bottom: 20px;">
							<tr>
								<td>
									Si no tienes huella, introduzca el código de empleado
								</td>
							</tr>
							<tr>
								<td>
									<input type="text" id="txtEmpCode" class="form-control input-sm" value="" placeholder="8-154-5555" autocomplete="off">
								</td>
							</tr>
							<tr>
								<td>
								
									<div style="display:none" id="keyboard-container">
										<input type="button" value=" 1 " onclick="form0.txtEmpCode.value += '1'" />
										<input type="button" value=" 2 " onclick="form0.txtEmpCode.value += '2'" />
										<input type="button" value=" 3 " onclick="form0.txtEmpCode.value += '3'" />
										<br/>
										
										<input type="button" value=" 4 " onclick="form0.txtEmpCode.value += '4'" />
										<input type="button" value=" 5 " onclick="form0.txtEmpCode.value += '5'" />
										<input type="button" value=" 6 " onclick="form0.txtEmpCode.value += '6'" />
										</br>
									  
										<input type="button" value=" 7 " onclick="form0.txtEmpCode.value += '7'" />
										<input type="button" value=" 8 " onclick="form0.txtEmpCode.value += '8'" />
										<input type="button" value=" 9 " onclick="form0.txtEmpCode.value += '9'" />
										</br>
									
										<input type="button" value=" 0 " onclick="form0.txtEmpCode.value += '0'" />
										<input type="button" value=" - " onclick="form0.txtEmpCode.value += '-'" />
										<input type="button" value=" OK " id="btn-manual" />
									</div>
								</td>
							</tr>
						</table>
						
                        <p class="lead">Informaci&oacute;n</p>
                        <p>Nombre: <span id="name"></span></p>    
                        <p>C&eacute;dula: <span id="pid"></span></p>   
                        <p>Compa&ntilde;&iacute;a: <span id="company"></span></p>   
                        <p>No.Empleado: <span id="no_emp"></span></p> 
                        <p>
                          <img src="<%=dir%>/images/default-avatar.png" width="100px" height="100px" style="border:blue 1px solid" id="photo">
                        </p>    
                        <p id="hist-container" style="height: 150px;overflow:scroll;display:none;"></p>    
                    </div>
                    
                    <%=fb.hidden("mode",mode)%>
                    <%=fb.hidden("fp",fp)%>
                    <%=fb.hidden("type",type)%>
                    <%=fb.hidden("ckSample",ckSample)%>
                    <%=fb.hidden("proceed", "")%>
                    <%=fb.hidden("alert_msg", "")%>
                    <%=fb.hidden("saved", "")%>
                    <%=fb.hidden("tipo_marcacion", "")%>
                    <%=fb.formEnd(true)%>
                </td>
            </tr>
        </table>
        
        
     </div> <!-- site-wrapper-inner -->
    </div> <!-- site-wrapper -->
    
    <script src="<%=dir%>/js/jquery.js"></script>
    <script src="<%=dir%>/js/global.js"></script>
    <script src="<%=dir%>/js/aes.js"></script>
	
    
    <script> 	
        function dataAcquiredHandler(){
            var appObj = document.getElementById("fpApp");
            
            if(appObj.getUrlKey() != null && appObj.getUrlKey().trim() != ''){
                getDetails(appObj.getUrlKey());
            } else {
                alert("El sistema no te puede identificar. Por favor contacte el administrador o recurso humano para registrar tus huellas.");
                window.location.reload();
            }
        }
        
        function processHistory(data){
           var $c = $("#hist-container");
           var content = "";
           JSON.parse(data).forEach(function(hist) {
              content += hist.f_marcacion + ": " + hist.tipo_marcacion_dsp + "<br>";
           });
           
           $c.html(content).show();
        }

        function getDetails(owner){
            var srvAlert = $("#alert_msg").val();
            var tipo = $("#tipo_marcacion").val();
            
            if (!tipo) {
               alert("Por favor tocar el botón indicando el tipo de marcación.");
               window.location.reload();
               return false; // :)
            }
            
            $.ajax({
              url: './index.jsp', 
              method: 'POST', 
              data: {owner:owner, tipo_marcacion: tipo, action:'CHECK'},
            })
             .done(function(data){                 
                 processHistory(data.last_marcaciones);

                 if (data.owner_photo) $("#photo").attr('src', data.owner_photo);
                 $("#name").text(data.owner_name);
                 $("#pid").text(data.owner_pid);
                 $("#company").text(data.owner_company);
                 $("#no_emp").text(data.owner_employee_id);
                 
                 var _t = 2000;
                 
                 if (tipo == '5') _t = 5000;
				
                 setTimeout(function(){
                    location.reload();
                 }, _t);
	           })
             .fail(function(jqXHR, textStatus, errorThrown){
                $(".action-type").prop("disabled", false);
                
                if(jqXHR.status == 404 || errorThrown == 'Not Found'){ 
                    alert('Hubo un error 404, por favor contacte un administrador!'); 
                }else{
                    
                    if (jqXHR.responseJSON.error) alert(jqXHR.responseJSON.msg);
                    else alert('Encontramos este error: '+errorThrown);
                }
             });
        }
		
		$(function(){
			$(".action-type").click(function(e){
			  $(".action-type").prop("disabled", false).removeClass('bg-orange');
			  $(this).prop("disabled", true);
				var self = $(this);
				var type = self.data('type');
				if (type) {
					$("#tipo_marcacion").val(type);
					$("#tbl-alt").show(0);
					self.addClass('bg-orange')
				}
			});
			
			
			// manual marcación
			$("#btn-manual").click(function(e) {
				var self = $(this);
				var txtEmpCode = $.trim($("#txtEmpCode").val());
				var tipoMarcacion = $("#tipo_marcacion").val();
								
				if (!txtEmpCode) {
					alert("Por favor ingrese el código de empleado")
				} else {
					self.prop("disabled", true);
					$(".action-type").prop("disabled", true);
					$("#txtEmpCode").prop("readOnly", true);
					
					$("#keyboard-container").hide();
					
					$.ajax({
					  url: './index.jsp', 
					  method: 'POST', 
					  data: {txtEmpCode:txtEmpCode, tipo_marcacion: tipoMarcacion, action:'MANUAL', },
					})
					 .done(function(data){						
						processHistory(data.last_marcaciones);
						
						if (data.owner_photo) $("#photo").attr('src', data.owner_photo);
						$("#name").text(data.owner_name);
						$("#pid").text(data.owner_pid);
						$("#company").text(data.owner_company);
						$("#no_emp").text(data.owner_employee_id);
						
						 var _t = 2000;
                 
						 if (tipoMarcacion == '5') _t = 5000;
						
						 setTimeout(function(){
							location.reload();
						 }, _t);
						
					 })
					 .fail(function(jqXHR, textStatus, errorThrown){
						if(jqXHR.status == 404 || errorThrown == 'Not Found'){ 
							alert('Hubo un error 404, por favor contacte un administrador!'); 
						}else{
							if (jqXHR.responseJSON.error) alert(jqXHR.responseJSON.msg);
							else alert('Encontramos este error: '+errorThrown);
						}
						
						self.prop("disabled", false);
						$(".action-type").prop("disabled", false);
						$("#txtEmpCode").prop("readOnly", false).val("");
					 });
				}
				
			});
			
			// 
			$("#txtEmpCode").click(function() {
				$("#keyboard-container").show();
			});

			$(".pad").click(function() {
				var val = this.innerHTML
				
				$("#txtEmpCode").val(function() {
					return this.value + val;
				});
			});
		});
    </script>
  </body>
</html>
<%
} else {

  com.google.gson.Gson gson = new com.google.gson.Gson();
  com.google.gson.JsonObject json = new com.google.gson.JsonObject();

  json.addProperty("date", System.currentTimeMillis());
  response.setContentType("application/json");
    
    if (owner.equals("")) owner = request.getParameter("owner");
    
    String action = request.getParameter("action")==null?"":request.getParameter("action");
    StringBuffer sbSql = new StringBuffer();
    String data = "";
    CommonDataObject cdo = new CommonDataObject();
	
	System.out.println(".................................. action = "+action);

    if (action.equalsIgnoreCase("manual")) {
				
		try {
			sbSql = new StringBuffer();

			sbSql.append("SELECT nombre_empleado owner_name, cedula1 pid, (select nombre from tbl_sec_compania where codigo = compania) AS company, num_empleado num_employee, compania as compania_id, emp_id AS owner_id");
			
			String empimage = "";
			try {empimage = java.util.ResourceBundle.getBundle("path").getString("empimages");} catch(Exception e) {}
			
			sbSql.append(", decode(foto,null,' ','");
			sbSql.append(empimage);
			sbSql.append("/'||foto) foto from vw_pla_empleado where (CEDULA1 = '");
			sbSql.append(request.getParameter("txtEmpCode"));
			sbSql.append("' OR NUM_EMPLEADO = '");
			sbSql.append(request.getParameter("txtEmpCode"));
			sbSql.append("') AND sin_huella = 'S'"); 
			
			cdo = SQLMgr.getData(sbSql.toString());
			if (cdo == null) cdo = new CommonDataObject();
			
			if (!"".equals(cdo.getColValue("owner_name", " ").trim())) {
				json.addProperty("owner_id", cdo.getColValue("owner_id"));
				json.addProperty("owner_name", cdo.getColValue("owner_name"));
				json.addProperty("owner_pid", cdo.getColValue("pid"));
				json.addProperty("owner_company", cdo.getColValue("company"));
				json.addProperty("owner_employee_id", cdo.getColValue("num_employee"));
				json.addProperty("owner_photo", cdo.getColValue("foto"));
								
				cdo.setTableName("tbl_pla_temp_marcacion");
				cdo.addColValue("fecha_marcacion", "sysdate");
				cdo.addColValue("emp_id", cdo.getColValue("owner_id"));
				cdo.addColValue("tipo_marcacion", request.getParameter("tipo_marcacion"));
				cdo.addColValue("compania", cdo.getColValue("compania_id"));
				cdo.addColValue("num_empleado", cdo.getColValue("num_employee"));
				cdo.addColValue("manual", "Y");
				cdo.addColValue("ip", request.getRemoteAddr());
				
				if (request.getParameter("tipo_marcacion").equals("5")) SQLMgr.setErrCode("1");
				else SQLMgr.insert(cdo);
				
				if (owner == null || "".equals(owner)) owner = cdo.getColValue("owner_id");
			} else {
				json.addProperty("error", true);
				json.addProperty("msg", "El empleado con el identificador: "+request.getParameter("txtEmpCode")+" no existe o debe marcar con la huella.");
				
				SQLMgr.setErrCode("2");
				SQLMgr.setErrMsg("El empleado con el identificador: "+request.getParameter("txtEmpCode")+" no existe o debe marcar con la huella.");
				SQLMgr.setErrException("El empleado con el identificador: "+request.getParameter("txtEmpCode")+" no existe o debe marcar con la huella.");
			}
		} catch(Exception up) {
			System.out.println(".................................. up = "+up.getMessage());
		}
	} else if (action.equalsIgnoreCase("check")) {

        sbSql = new StringBuffer();
        sbSql.append("select z.owner_id, (select nombre_empleado from vw_pla_empleado where emp_id = z.owner_id) as owner_name, (select cedula1 from vw_pla_empleado where emp_id = z.owner_id) as cedula, (select compania from vw_pla_empleado where emp_id = z.owner_id) as compania, (select num_empleado from vw_pla_empleado where emp_id = z.owner_id) as num_empleado");
        
        String empimage = "";
        try {empimage = java.util.ResourceBundle.getBundle("path").getString("empimages");} catch(Exception e) {}
		
        sbSql.append(", (select decode(foto,null,' ','");
        sbSql.append(empimage);
        sbSql.append("/'||foto) from vw_pla_empleado where emp_id = z.owner_id) as foto");
		
        sbSql.append(" from tbl_bio_fingerprint z where z.capture_type = 'EMP' and z.owner_id = ");
        sbSql.append(owner);
        
        cdo = SQLMgr.getData(sbSql.toString());
        if (cdo == null) cdo = new CommonDataObject();
                
        json.addProperty("owner_id", cdo.getColValue("owner_id"));
        json.addProperty("owner_name", cdo.getColValue("owner_name"));
        json.addProperty("owner_pid", cdo.getColValue("cedula"));
        json.addProperty("owner_company", cdo.getColValue("compania"));
        json.addProperty("owner_employee_id", cdo.getColValue("num_empleado"));
        json.addProperty("owner_photo", cdo.getColValue("foto"));

        cdo.setTableName("tbl_pla_temp_marcacion");
        cdo.addColValue("fecha_marcacion", "sysdate");
        cdo.addColValue("emp_id", owner);
        cdo.addColValue("tipo_marcacion", request.getParameter("tipo_marcacion"));
        cdo.addColValue("compania", cdo.getColValue("compania"));
        cdo.addColValue("num_empleado", cdo.getColValue("num_empleado"));
        cdo.addColValue("ip", request.getRemoteAddr());
        
        if (request.getParameter("tipo_marcacion").equals("5")) SQLMgr.setErrCode("1");
        else SQLMgr.insert(cdo);
    }
    
    if(SQLMgr.getErrCode().equals("1")) {
        
        if(action.equalsIgnoreCase("check") || action.equalsIgnoreCase("manual")) {
            
            ArrayList al = SQLMgr.getDataList("select to_char(fecha_marcacion, 'dd/mm/yyyy hh:mi:ss am') f_marcacion, decode(tipo_marcacion, 1,'Entrada', 2, 'Salida Almuerzo', 3, 'Entrada Almuerzo', 4, 'Salida') tipo_marcacion_dsp from tbl_pla_temp_marcacion where fecha_marcacion >= sysdate - 12/24 and emp_id = "+owner+" order by tipo_marcacion, fecha_marcacion");
            
            ArrayList al2 = new ArrayList();
            
            for (int i = 0; i < al.size(); i++) {
              cdo = (CommonDataObject) al.get(i);
              al2.add(cdo.getColValues());
            }
    
            json.addProperty("last_marcaciones", gson.toJson(al2));

            out.print(gson.toJson(json));
            return;		
        }
        
    } else {

        response.setStatus(500);
        json = new com.google.gson.JsonObject();
        json.addProperty("error", true);
        json.addProperty("msg", SQLMgr.getErrException());
        
        out.print(gson.toJson(json));
        return;
    } 
}
%>