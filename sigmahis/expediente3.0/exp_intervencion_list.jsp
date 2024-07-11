<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.ArrayList" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String idEscala = request.getParameter("id_escala");
int total = Integer.parseInt(request.getParameter("total")==null?"0":request.getParameter("total"));
String compania = (String) session.getAttribute("_companyId");
String mode = request.getParameter("mode");
if (mode == null) mode = "add";

if (fg == null) fg = "DO";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
  if (fg.trim().equals("DO")) cdo = SQLMgr.getData("select nvl(get_sec_comp_param("+compania+",'EXP_INTERV_ESCALAS_DO'),'') as color from dual");
  else if (fg.trim().equals("MM5")) cdo = SQLMgr.getData("select '1-3:GREEN:BAJO,3-4:YELLOW:MEDIO,4-5:RED:ALTO' as color from dual");
  else if (fg.trim().equals("BR")) cdo = SQLMgr.getData("select '19-100:GREEN:BAJO,16-18:YELLOW:MEDIO,0-16:RED:ALTO' as color from dual");
  else if (fg.trim().equals("CA")) cdo = SQLMgr.getData("select '0-3:GREEN:BAJO,4-6:YELLOW:MEDIO,7-10:RED:ALTO' as color from dual");
  else if (fg.trim().equals("MAC")) cdo = SQLMgr.getData("select '0-2:GREEN:BAJO,3-100:RED:ALTO' as color from dual");
  else if (fg.trim().equals("TVP")) cdo = SQLMgr.getData("select '0-1:GREEN:BAJO,2-2:YELLOW:MEDIO,3-4:RED:ALTO,5-100:RED:EXTREMADO' as color from dual");
  else if (fg.trim().equals("SG")) cdo = SQLMgr.getData("select '0-100:YELLOW:SUSAN' as color from dual");
  else cdo = SQLMgr.getData("select nvl(get_sec_comp_param("+compania+",'EXP_INTERV_ESCALAS'),'') as color from dual");
  
  if (cdo==null) cdo = new CommonDataObject();
  String _color = cdo.getColValue("color");  //0-3:green,4-6:yellow,7-10:red
  String colorClass = "";
  String level = "";
   
  try{
	String[] c1 = _color.split(","); //0-3:green
	for (int a=0;a<c1.length;a++){
	  String[] c2 = c1[a].split(":"); //0-3,green,bajo
	  String[] c3 = c2[0].split("-"); //0,3
	  int from = Integer.parseInt(c3[0]);
	  int to = Integer.parseInt(c3[1]);
	  if (total >= from && total <= to){
	    colorClass=c2[1].toLowerCase();
		level =c2[2].toLowerCase(); 
		break;
	  }
	}
	String[] c2 = _color.split(",");
  }catch(Exception e){System.out.println("::::::::::::::::::::::::::::: Error al buscar los colores de la cabecera de la  intervención");e.printStackTrace();}
  
  //tbl_sal_intervencion_paciente
  ArrayList al = SQLMgr.getDataList("select i.codigo, i.descripcion, i.valorizacion, ip.observacion, decode(ip.cod_intervencion,null,'I','U') accion from tbl_sal_intervencion i, tbl_sal_intervencion_paciente ip where i.estado = 'A' and i.tipo = '"+fg+"' and i.codigo = ip.cod_intervencion(+) and ip.pac_id(+) = "+pacId+" and ip.admision(+) = "+noAdmision+" and ip.id_escala(+) = "+idEscala+" and i.tipo = ip.tipo(+) order by 1 ");
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script>
document.title = 'ESCALAS - '+document.title;

$(function(){
	var highLight = {"bajo" : "<%=colorClass%>","medio" : "<%=colorClass%>","alto" : "<%=colorClass%>"};
	if ("<%=level%>" == "bajo") {
        $("#low").css("background-color","<%=colorClass%>");
        $(".medium, .high, .extreme, #btn-medium, #btn-high, #btn-extreme").prop("disabled", true);
        $("#observacion_medium, #observacion_high, #observacion_extreme").prop('readOnly', true);
    }
	else if ("<%=level%>" == "medio") {
        $("#medium").css({"background-color":"<%=colorClass%>","color":"#000"});
        $(".low, .high,.extreme, #btn-low, #btn-high, #btn-extreme").prop("disabled", true);
        $("#observacion_low, #observacion_high").prop('readOnly', true);
    }
	else if ("<%=level%>" == "alto") {
        $("#high").css("background-color","<%=colorClass%>");
        $(".low, .medium,.extreme, #btn-low, #btn-medium, #btn-extreme").prop("disabled", true);
        $("#observacion_low, #observacion_medium").prop('readOnly', true);
    }
	else if ("<%=level%>" == "extremado") {
        $("#extreme").css("background-color","<%=colorClass%>");
        $(".low, .medium,.high, #btn-low, #btn-medium, #btn-high").prop("disabled", true);
        $("#observacion_low, #observacion_medium, #observacion_high").prop('readOnly', true);
    }
    else if ("<%=level%>" == "susan") {
        $("#susan").css({"background-color":"<%=colorClass%>","color":"#000"});
    }
    
    $(".btn-save-interv").click(function(e){
        e.preventDefault();
        var that = $(this);

        var codInterv = that.data('cod-interv');
        var totDet = that.data('index-det');
        var valorizacion = that.data('valorizacion');
        var codigoIntervPac = that.data('codigo-interv-pac');
        var accion = that.data('accion');
        var idEscala = that.data('idescala');
        var observacion = $.trim($("#observacion_"+valorizacion).val());
        
        var fData = {
            codInterv: codInterv,
            totDet: totDet,
            valorizacion: valorizacion,
            observacion: observacion,
            pacId: "<%=pacId%>",
            noAdmision: "<%=noAdmision%>",
            tipo: "<%=fg%>",
            codigoIntervPac: codigoIntervPac,
            accion: accion,
            id_escala: idEscala,
        };
        var aplicando = false;
        for (var i = 0; i<parseInt(totDet,10); i++) {
          if( $("#aplicar_"+codInterv+'_'+i).length && $("#aplicar_"+codInterv+'_'+i).is(":checked") )  {
            fData["aplicar_"+codInterv+'_'+i] =  "S";
            aplicando = true;
          } else fData["aplicar_"+codInterv+'_'+i] =  "N";
          fData['cod-det-'+codInterv+'-'+i] =  $("#cod-det-"+codInterv+"-"+i).val();
          fData['aplicado-'+codInterv+'-'+i] =  $("#aplicado-"+codInterv+"-"+i).val();
          //debug($("#cod-det-"+codInterv+"-"+i))
        }

        if (observacion || aplicando){
            that.attr("disabled", true);        
            $.post('../expediente3.0/exp_intervencion_list.jsp', fData)
             .done(function(response){
                response = $.trim(response);
                if (response && response != 'SUCCESS') {
                  that.attr("disabled", false);
                  CBMSG.error(response);
                } else {
                    that.attr("disabled", false);
                    CBMSG.alert("Se han guardado satisfactoriamente las intervenciones!", {
                      cb: function(r) {
                        if (r == 'Ok') {
                          if (typeof parent.hideModal === 'function') parent.hideModal();
                          else if (typeof parent.parent.hideModal === 'function') parent.parent.hideModal();
                        }
                      }
                    });
                }
              })
             .fail(function(xhr, status, statusText){
               CBMSG.error(statusText);
               that.attr("disabled", false);
             });
         } else CBMSG.error("Por favor seleccione por lo menos una intervención!");
    }); 
});
</script>
<style>
  .table>tbody>tr>td, .table>tbody>tr>th, .table>tfoot>tr>td, .table>tfoot>tr>th, .table>thead>tr>td, .table>thead>tr>th {vertical-align:top !important;}
  <%if(!fg.trim().equals("DO")){%>
  ul{list-style-type: none;}
  <%}%>
  li{padding-bottom:5px}
  .highlight{background-color:<%=colorClass%>;color:#000;font-style:bold;}
</style>
</head>
<body class="body-form">
<div class="row">    
    <div class="table-responsive" data-pattern="priority-columns">
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("id_escala",idEscala)%>

                <table cellspacing="0" width="100%" class="table table-bordered table-striped" id="printing-content">
                <tr align="center" class="bg-headtabla2">
                    <%
                        int noCols = al.size(); 
                        for (int i = 0; i < al.size(); i++){ 
                        cdo = (CommonDataObject) al.get(i);
                        double w = 100 / noCols;
                    %>
                        <td class="headers" width="<%=w%>%" id="<%=cdo.getColValue("valorizacion")%>"><%=cdo.getColValue("descripcion")%></td>                
                    <% } %>
                </tr>
                
                <%
                
                for (int h = 0; h < al.size(); h++) {
                CommonDataObject cdoH = (CommonDataObject) al.get(h);
                %>
                <td class="details">
                   <table cellspacing="0" width="100%" class="table table-bordered table-striped int-det">
                         <%
                         String sqlD = "select id.cod_intervencion, id.codigo, id.descripcion , id.mostrar_checkbox, decode(ipd.cod_interv_det,null,'N','S') aplicado from tbl_sal_intervencion_det id, tbl_sal_intervencion_pac_det ipd where id.cod_intervencion = '"+cdoH.getColValue("codigo")+"' and id.cod_intervencion = ipd.cod_intervencion(+) and id.codigo = ipd.cod_interv_det(+) and ipd.pac_id(+) = "+pacId+" and ipd.admision(+) = "+noAdmision+" and ipd.id_escala(+) = "+idEscala+" and id.tipo = '"+fg+"' and id.tipo = ipd.tipo(+) order by id.cod_intervencion, id.codigo ";
                         ArrayList alD = SQLMgr.getDataList(sqlD);%>
                        <% for ( int d = 0; d < alD.size(); d++){
                            
                            CommonDataObject cdoD = (CommonDataObject) alD.get(d);%>
                               <%if(cdoD.getColValue("cod_intervencion").equals(cdoH.getColValue("codigo")) ){%>
                                   <tr>
                                     <td class="int-det-text"> 
                                     <%if (cdoD.getColValue("mostrar_checkbox") != null && cdoD.getColValue("mostrar_checkbox").equalsIgnoreCase("S")){%>
                                       <label class="pointer">
                                       <%=fb.checkbox("aplicar_"+cdoH.getColValue("codigo")+"_"+d,"S",cdoD.getColValue("aplicado").equalsIgnoreCase("S"),viewMode,""+cdoH.getColValue("valorizacion"),null,"")%>
                                       <%=cdoD.getColValue("codigo")%>.&nbsp;<%=cdoD.getColValue("descripcion")%></label>
                                     <%}else {%>
                                     <%=cdoD.getColValue("codigo")%>.&nbsp;<%=cdoD.getColValue("descripcion")%>
                                     <%}%>
                                     
                                     </td>
                                   </tr>
                                   <input type="hidden" name="cod-det-<%=cdoH.getColValue("codigo")%>-<%=d%>" id="cod-det-<%=cdoH.getColValue("codigo")%>-<%=d%>" value="<%=cdoD.getColValue("codigo")%>">
                                   <input type="hidden" name="aplicado-<%=cdoH.getColValue("codigo")%>-<%=d%>" id="aplicado-<%=cdoH.getColValue("codigo")%>-<%=d%>" value="<%=cdoD.getColValue("aplicado")%>">
                               <%}%>      
                        <%}%>
                        <tr>
                            <td>
                            <div class="form-inline">
                            <%=fb.textarea("observacion_"+cdoH.getColValue("valorizacion"),cdoH.getColValue("observacion"),false,false,viewMode,0,0,2000,"form-control input-sm","width:60%",null)%>
                            <button class="btn btn-sm btn-inverse btn-save-interv" 
                            data-cod-interv="<%=cdoH.getColValue("codigo")%>" data-index-det="<%=alD.size()%>"
                            data-valorizacion="<%=cdoH.getColValue("valorizacion")%>"
                            data-codigo-interv-pac="<%=cdoH.getColValue("cod_interv_pac")%>"
                            data-accion="<%=cdoH.getColValue("accion")%>"
                            data-idescala="<%=idEscala%>"
                            <%=viewMode?" disabled":""%>
                            id="btn-<%=cdoH.getColValue("valorizacion")%>"
                            >
                                <i class="fa fa-floppy-o fa-lg"></i>&nbsp;Ok
                            </button>
                            </div>
                            </td>
                        </tr>
                        
                  </table>
                </td>
            
                <%}%>
				<%=fb.formEnd(true)%>
			</table>
			</div>
			</div>
		
</body>
</html>
<%
}else {
   ArrayList al = new ArrayList();
   
   int totDet = Integer.parseInt(request.getParameter("totDet") == null ? "0" : request.getParameter("totDet"));
   String codInterv = request.getParameter("codInterv");
   
   String where = "pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision");

   cdo = new CommonDataObject();
   cdo.setTableName("tbl_sal_intervencion_paciente");
   cdo.addColValue("observacion", request.getParameter("observacion"));
   cdo.addColValue("tipo", request.getParameter("tipo"));
   cdo.setAction(request.getParameter("accion"));

   if (cdo.getAction() != null && cdo.getAction().equalsIgnoreCase("I") ) {     
     cdo.addColValue("pac_id", request.getParameter("pacId"));
     cdo.addColValue("admision", request.getParameter("noAdmision"));
     cdo.addColValue("cod_intervencion", request.getParameter("codInterv"));
     cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
     cdo.addColValue("fecha_creacion", "sysdate");
     cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
     cdo.addColValue("fecha_modificacion", "sysdate");
     cdo.addColValue("id_escala", request.getParameter("id_escala"));
   } else {
     cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
     cdo.addColValue("fecha_modificacion", "sysdate");
     where += " and cod_intervencion = "+codInterv+" and id_escala = "+request.getParameter("id_escala")+" and tipo = '"+request.getParameter("tipo")+"'";
   }
   cdo.setWhereClause(where);
    
    int selected = 0;
    for (int i = 0; i < totDet; i++) {
        CommonDataObject cdo2 = new CommonDataObject();
        cdo2.setTableName("tbl_sal_intervencion_pac_det");

        String aplicar = request.getParameter("aplicar_"+codInterv+"_"+i);
        String aplicado = request.getParameter("aplicado-"+codInterv+"-"+i);
        String codDet = request.getParameter("cod-det-"+codInterv+"-"+i);
        
        if ( aplicar != null && aplicar.equalsIgnoreCase("S") ){
        
            System.out.println("------------------------------------ aplicar = S");
            
            if (aplicado != null && aplicado.equalsIgnoreCase("S")) {
              System.out.println("------------------------------------ aplicado = S");
              cdo2.setAction("U");
              cdo2.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and cod_intervencion = "+codInterv+" and cod_interv_det = "+codDet+" and id_escala = "+request.getParameter("id_escala")+" and tipo = '"+request.getParameter("tipo")+"'");

              cdo2.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
              cdo2.addColValue("fecha_modificacion", "sysdate");
            }else {
            System.out.println("------------------------------------ aplicado = N");
              cdo2.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
              cdo2.addColValue("fecha_creacion", "sysdate");
              cdo2.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
              cdo2.addColValue("fecha_modificacion", "sysdate");
              cdo2.setAction("I");
              cdo2.addColValue("cod_interv_det", codDet);
              cdo2.addColValue("pac_id", request.getParameter("pacId"));
              cdo2.addColValue("admision", request.getParameter("noAdmision"));
              cdo2.addColValue("cod_intervencion", codInterv);
              cdo2.addColValue("id_escala", request.getParameter("id_escala"));
              cdo2.addColValue("tipo", request.getParameter("tipo"));
            }
            selected++;
        } else {

           if (aplicado != null && aplicado.equalsIgnoreCase("S")) {
                cdo2.setAction("D");
                cdo2.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and cod_intervencion = "+codInterv+" and cod_interv_det = "+codDet+" and id_escala = "+request.getParameter("id_escala"));
                selected++;
            }
        }
        
        if (selected > 0) al.add(cdo2);
    }

    SQLMgr.save(cdo, al, true ,true, true, true);
    
    if (SQLMgr.getErrCode().equals("1")) out.print("SUCCESS");
    else out.print(SQLMgr.getErrMsg());
}
%>