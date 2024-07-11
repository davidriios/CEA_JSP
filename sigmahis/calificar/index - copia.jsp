<%@ page trimDirectiveWhitespaces="true" %>
<%//@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.ConnectionMgr"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.CommonDataObject"%>
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
if (type == null) type = "PAC";
if (owner == null) owner = "";
if (ckSample == null) ckSample = "1";
String cds = "";
String cdsDesc = "";
String idMachine = "";

if (request.getMethod().equalsIgnoreCase("GET")){
    if (!CmnMgr.isValidFpType(type)) throw new Exception("El Tipo de Huella Dactilar no está habilitada. Por favor consulte con su administrador!");
    if (type.trim().equals("")) throw new Exception("Tipo de Captura inválida!");
    
    CommonDataObject cdo = SQLMgr.getData("select id as id_machine, cds, cds_desc from TBL_CDS_MACHINES where status = 'A' and ip = '"+request.getRemoteAddr()+"'");
    if (cdo == null) cdo = new CommonDataObject();
    
    cds = cdo.getColValue("cds"," ");
    cdsDesc = cdo.getColValue("cds_desc"," ");
    idMachine = cdo.getColValue("id_machine"," ");
    
    if (cds.trim().equals("")) throw new Exception("La máquina no está configurada con el Centro de Servicio. Por favor consulte con su administrador!");

    String mode = request.getParameter("mode");
    boolean viewMode = false;
    if (mode == null) mode = "add";
    if (mode.equalsIgnoreCase("view")) viewMode = true;

    //
    StringBuffer sbComm = new StringBuffer();

    cdo = SQLMgr.getData("select nvl(get_sec_comp_param(0,'SEC_APP_SERV_COMM_HOST'),' ') as appServCommHost from dual");
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

    <title>CellByte Rating</title>

    <link href="../css/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <link href="../css/bootstrap/css/font-awesome.min.css" rel="stylesheet">
    <link href="../css/employee_control.css" rel="stylesheet">
    
    <style>
		.mr-10{margin-right: 50px}
		.btn-primary.focus, .btn-primary:focus {
          background-color: orange;
        }
        .icon {
          width: 150px;
          hight: 150px;
          cursor: pointer;
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
        <%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
        <%=fb.formStart(true)%>
        
        
        <tr style="text-align: left">
          <td colspan="2">
            <input type="text" placeholder="C&eacute;dula o usa el lector si est&aacute; registrado(a)" style="margin-left: 30px; width: 30%;color:#000;" value="" name="tmp-cedula" id="tmp-cedula"> <br>
            
            <div id="icons-container" style="margin-left: 30px; font-size: 20em; cursor: pointer">
            
              <i class="fa fa-smile-o" style="color: green; cursor: pointer;" title="Satisfecho"></i>
              <i class="fa fa-meh-o" style="color: yellow; cursor: pointer;" title="Mas o menos"></i>
              <i class="fa fa-frown-o" style="color: red; cursor: pointer;" title="Nada Satisfecho"></i>
            </div>

             <!-- 
            <img data-rating="2" src="<%=request.getContextPath()%>/images/icons/rating-happy.png" class="icon" alt="Satisfecho" title="Satisfecho">
            <img data-rating="1" src="<%=request.getContextPath()%>/images/icons/rating-ok.png" class="icon" alt="Mas o menos" title="Mas o menos">
            <img data-rating="0" src="<%=request.getContextPath()%>/images/icons/rating-pissed.png" class="icon" alt="Nada Satisfecho" title="Nada Satisfecho">
            -->
            
            <br>
            
            <span id="fg-indicator" style="margin-left: 30px; display: none">Por favor tocar el botón indicando el grado de satisfación.</span>
            
          </td>
        </tr>
			
			<!--
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
                    </div>
                </td>
                
                <td>
                    
                    
                    <div class="inner cover" style="text-align: left">
                        <p class="lead">Informaci&oacute;n</p>
                        <p>CDS: <span>[<%=cds%>] <%=cdsDesc%></span></p>
                        <p>Nombre: <span id="pac-name"></span></p>
                        <p>C&eacute;dula: <span id="pac-cedula"></span></p>
                        <p>PID: <span id="pid"></span></p>
                           
                    </div>
                    
                    
                </td>
            </tr>
            -->
            
            
            <%=fb.hidden("mode",mode)%>
            <%=fb.hidden("fp",fp)%>
            <%=fb.hidden("type",type)%>
            <%=fb.hidden("ckSample",ckSample)%>
            <%=fb.hidden("proceed", "")%>
            <%=fb.hidden("alert_msg", "")%>
            <%=fb.hidden("saved", "")%>
            <%=fb.hidden("rating", "")%>
            <%=fb.hidden("wait-pac-fetching", "")%>
            <%=fb.hidden("pac-fetching-succed", "")%>
            <%=fb.hidden("from_fg", "")%>
            <%=fb.hidden("pac_id", "")%>
            <%=fb.hidden("admision", "")%>
            <%=fb.hidden("cedula", "")%>
            <%=fb.hidden("cds", cds)%>
            <%=fb.hidden("cds_desc", cdsDesc)%>
            <%=fb.hidden("id_machine", idMachine)%>
            <%=fb.formEnd(true)%>
        </table>
        
        
     </div> <!-- site-wrapper-inner -->
    </div> <!-- site-wrapper -->
    
    <script src="../js/jquery.js"></script>
    <script src="../js/global.js"></script>
    <script src="../js/aes.js"></script>
    
    <script>        
        function dataAcquiredHandler(){
            var appObj = document.getElementById("fpApp");
            
            if(appObj.getUrlKey() != null && appObj.getUrlKey().trim() != ''){
                $("#pac_id").val(appObj.getUrlKey());
                $("#from_fg").val("Y");
                doSubmit(1);
            } else {
                alert("El sistema no te puede identificar. Por favor contacte el administrador o recurso humano para registrar tus huellas.");
            }
        }
        
        function doSubmit(fg){
            var pacId = $("#pac_id").val();
            var admision = $("#admision").val();  
            var cedula = $("#cedula").val();  
            
            var srvAlert = $("#alert_msg").val();
            var rating = $("#rating").val();
            var wating = $("#wait-pac-fetching").val() != "";
                        
            if (fg) {
              if (rating === "") {
                $("#fg-indicator").show(0);
                return false; // :)
              }
            }
			
            $.post('./index.jsp', {
                pac_id: pacId,
                rating: rating,
                admision: admision,
                cedula: cedula,
                from_fg: $("#from_fg").val(),
                cds: "<%=cds%>",
                id_machine: "<%=idMachine%>",
                action:'SAVE',
             }, function(data){
             
                if (data.from_fg) {
                    $("#pac-name").text(data.owner_name);
                    $("#pid").text(data.owner_id);
                    $("#pac-cedula").text(data.cedula);
                
                    $("#pac_id").val(data.owner_id);
                    $("#cedula").val(data.cedula);
                    $("#admision").val(data.admision);
                    
                    setTimeout(function(){
                      location.reload();
                    }, 2000);
                    
                } else {
                    location.reload();
                }
             }, 'json')
             .fail(function(jqXHR, textStatus, errorThrown){
                if (msg = jqXHR.responseJSON.msg) alert(msg)
                else if(jqXHR.status == 404 || errorThrown == 'Not Found'){ 
                    alert('Hubo un error 404, por favor contacte un administrador!'); 
                }else{
                    alert('Encontramos este error: '+errorThrown);
                }
             });
        }
		
		$(function(){
			$(".icon").click(function(e){
				var self = $(this);
				var rating = self.data('rating');
				if (rating !== "")  {
          $("#rating").val(rating);
          doSubmit();
        }
			});
			
			
			// cedula
			
			$("#tmp-cedula").focus(function(e) {
          this.value = '';
          
          $("#pac-name").text("");
          $("#pid").text("");
          $("#pac-cedula").text("");
          $("#pac_id").val("");
          $("#cedula").val("");
          $("#admision").val("");
      });
			
			$("#tmp-cedula").blur(function(e) {

        if ( cedula = $.trim(this.value) ) {
        
          $("#wait-pac-fetching").val("Y");
           
          $.post('./index.jsp', {action:'FETCH_PATIENT', cedula: cedula}, function(data) {
                $("#pac-name").text(data.nombre_paciente);
                $("#pid").text(data.pac_id+"-"+data.admision);
                $("#pac-cedula").text(data.cedula);
                
                $("#pac_id").val(data.pac_id);
                $("#cedula").val(data.cedula);
                $("#admision").val(data.admision);
                
                $("#pac-fetching-succed").val("Y");
                $("#wait-pac-fetching").val("");
                
                $("#fg-indicator").show(0);
             }, 'json')
             .fail(function(jqXHR, textStatus, errorThrown){
                
                if(jqXHR.status == 404 || errorThrown == 'Not Found'){ 
                    alert('Hubo un error 404, por favor contacte un administrador!'); 
                }else{
                    alert('Encontramos este error: '+errorThrown);
                }
             });
        }
			});
			
			
			
		});
    </script>
  </body>
</html>
<%
} else {
    
    if (owner.equals("")) owner = request.getParameter("pac_id");
    if (cds.equals("")) cds = request.getParameter("cds");
    if (idMachine.equals("")) idMachine = request.getParameter("id_machine");
    
    String action = request.getParameter("action")==null?"":request.getParameter("action");
    StringBuffer sbSql = new StringBuffer();
    String data = "";
    String pacId = request.getParameter("pac_id");
    String admision = request.getParameter("admision");
    String cedula = request.getParameter("cedula");
    CommonDataObject cdo = new CommonDataObject();

    if (action.equalsIgnoreCase("save")) {
    
        if (request.getParameter("from_fg") != null && request.getParameter("from_fg").equalsIgnoreCase("Y")) {
           sbSql = new StringBuffer();
           sbSql.append("select z.owner_id, (select nombre_paciente from vw_adm_paciente where pac_id = z.owner_id) as owner_name, (select id_paciente_f3 from vw_adm_paciente where pac_id = z.owner_id) as cedula, (select max(secuencia) from tbl_adm_admision where pac_id = z.owner_id) as admision "); 
		
           sbSql.append(" from tbl_bio_fingerprint z where z.capture_type = 'PAC' and z.owner_id = ");
           sbSql.append(owner);
        
           cdo = SQLMgr.getData(sbSql.toString());
           if (cdo == null) cdo = new CommonDataObject();
                                      
            sbSql = new StringBuffer();
            sbSql.append("{");
            
            sbSql.append("\"owner_name\":\"");
            sbSql.append(cdo.getColValue("owner_name"));
            sbSql.append("\"");
            sbSql.append(",\"cedula\":");
            sbSql.append("\"");
            sbSql.append(cdo.getColValue("cedula"));
            sbSql.append("\"");
            sbSql.append(",\"pac_id\":");
            sbSql.append("\"");
            sbSql.append(cdo.getColValue("owner_id"));
            sbSql.append("\"");
            sbSql.append(",\"admision\":");
            sbSql.append("\"");
            sbSql.append(cdo.getColValue("admision"));
            sbSql.append("\"");
            sbSql.append(",\"owner_id\":");
            sbSql.append("\"");
            sbSql.append(cdo.getColValue("owner_id"));
            sbSql.append("\"");
            sbSql.append(",\"from_fg\":");
            sbSql.append("\"");
            sbSql.append("Y");
            sbSql.append("\"");
            sbSql.append("}");
         
            data = sbSql.toString();

            pacId = cdo.getColValue("owner_id");
            admision = cdo.getColValue("admision");
            cedula = cdo.getColValue("cedula");
                      
        }
        else {
            sbSql = new StringBuffer();
            sbSql.append("{");
            
            sbSql.append("\"msg\":");
            sbSql.append("\"");
            sbSql.append("success");
            sbSql.append("\"");
            sbSql.append("}");
         
            data = sbSql.toString();
        }
        
        cdo = new CommonDataObject();
        cdo.setTableName("TBL_CDS_RATINGS");
        cdo.setAutoIncCol("id");
        
        cdo.addColValue("cds", cds);
        cdo.addColValue("ip", request.getRemoteAddr());
        
        cdo.addColValue("pac_id", pacId);
        cdo.addColValue("admision", admision);
        cdo.addColValue("cedula", cedula);
        cdo.addColValue("rating", request.getParameter("rating"));
        cdo.addColValue("id_machine", idMachine);
        cdo.addColValue("fecha_creacion", "sysdate");
        
        SQLMgr.insert(cdo);
        
        if(SQLMgr.getErrCode().equals("1")) {
            response.setContentType("application/json");
            out.print(data);
        } else {
            
            System.out.println("========================================================== Error: "+SQLMgr.getErrException());
            
            sbSql = new StringBuffer();
            sbSql.append("{");
            
            sbSql.append("\"msg\":");
            sbSql.append("\"");
            sbSql.append(SQLMgr.getErrMsg());
            sbSql.append("\"");
            sbSql.append("}");
         
            data = sbSql.toString();
            
            response.setContentType("application/json");
            response.setStatus(500);
            out.print(data);
        }
    } 
    else if ( action.equalsIgnoreCase("FETCH_PATIENT") ) {
        
        cdo = SQLMgr.getData("select nombre_paciente, id_paciente_f3 as cedula, pac_id, (select max(secuencia) from tbl_adm_admision where pac_id = vw_adm_paciente.pac_id) admision from vw_adm_paciente where id_paciente_f3 like '%"+request.getParameter("cedula")+"%'");
        
        sbSql = new StringBuffer();
        sbSql.append("{");
        
        sbSql.append("\"nombre_paciente\":\"");
        sbSql.append(cdo.getColValue("nombre_paciente"));
        sbSql.append("\"");
        sbSql.append(",\"cedula\":");
        sbSql.append("\"");
        sbSql.append(cdo.getColValue("cedula"));
        sbSql.append("\"");
        sbSql.append(",\"pac_id\":");
        sbSql.append("\"");
        sbSql.append(cdo.getColValue("pac_id"));
        sbSql.append("\"");
        sbSql.append(",\"admision\":");
        sbSql.append("\"");
        sbSql.append(cdo.getColValue("admision"));
        sbSql.append("\"");
        sbSql.append("}");
        
        data = sbSql.toString();
        
        response.setContentType("application/json");
        out.print(data);
    }
}
%>