<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoP = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String cds = request.getParameter("cds");
String tab = request.getParameter("tab");
String __type = request.getParameter("type")==null?"R":request.getParameter("type");
String useTmpCdo = request.getParameter("useTmpCdo")==null?"":request.getParameter("useTmpCdo");
String compania = (String)session.getAttribute("_companyId");
String change = request.getParameter("change");
String key = "";
String curDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = (String)session.getAttribute("_userName");

if (tab == null) tab = "1";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (cds == null) cds = "";

cdoP = SQLMgr.getData(" select id, tipo, company_seq, cds_solicita, transferido_a, acompaniante_transf, parentesco_acompaniante, cond_transf, to_char(fecha_transferencia,'dd/mm/yyyy hh12:mi am') as fecha_transf, otras_condiciones observ_cond_transf, coordinador, area_coordinador, personal_translado, proveedor, to_char(fecha_seguimiento,'dd/mm/yyyy') fecha_seguimiento, to_char(hora_seguimiento,'hh12:mi:ss am') hora_seguimiento, condicion_seguimiento from tbl_sal_cons_incap_transf  where tipo = 'T' and status = 'A' and pac_id = "+pacId+" and admision = "+noAdmision+"");
	   
if (cdoP == null) {
 cdoP = new CommonDataObject();
 mode = "edit";
}

if (!useTmpCdo.trim().equals("")){
   cdoP = (CommonDataObject)session.getAttribute("iCdoP");
}else{session.removeAttribute("iCdoP");}

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
    
    ArrayList alTipos = SQLMgr.getDataList("select p.tipo, p.id, p.descripcion, decode(p.tipo,2,'REQUERIMIENTOS', 3, 'MOTIVOS', 4, 'DOCUMENTOS') as tipo_desc, d.id_trans_params, d.observacion, p.es_otro from tbl_sal_transferencia_params p, tbl_sal_transf_det d where p.status = 'A' and p.tipo in(2,3,4) and p.compania = 1 and p.tipo = d.tipo_transf_params(+) and p.id = d.id_trans_params(+)  and d.tipo(+) = '"+cdoP.getColValue("tipo")+"' and d.id_transf(+) = "+cdoP.getColValue("id")+" order by 1,2");
    
    CommonDataObject pacData = SQLMgr.getData("select to_char(fecha_nacimiento,'dd/mm/yyyy') fn, codigo from tbl_adm_paciente where pac_id = "+pacId);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<script>
var noNewHeight = true;
document.title = 'EXPEDIENTE - Datos de Salida - Transferencia - '+document.title;
function doAction(){}

function printCartaTraslado(){
   var idTransf = $("#id_transf").val();
	abrir_ventana("../expediente3.0/print_carta_traslado.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&idTransf="+idTransf);
}
function printDatos(){abrir_ventana("../expediente/print_ex_datos_salida.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>");}
function printRecetas(){
   abrir_ventana("../expediente/exp_gen_recetas.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&modeSec=<%=modeSec%>&seccion=<%=seccion%>");
}
function printConsIncap(tipo){
  var horaIncap = "<%=cdo.getColValue("hora_incap")==null?"":cdo.getColValue("hora_incap")%>";
  var diaIncap = "<%=cdo.getColValue("dia_incap")==null?"":cdo.getColValue("dia_incap")%>";
  
  if (horaIncap=="" && diaIncap == ""){
     alert("Por favor registre los datos antes de imprimir");
  }else{
	abrir_ventana("../expediente/exp_print_constancia_incapacidad.jsp?tipo="+tipo+"&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>");
  }
}

$(function(){
    $(".header").click(function(){
        var self = $(this);
        var tipo = self.data("tipo");
        $(".det_"+tipo).toggle();
    });
    
    $("#cond_transf").change(function(){
        var self = $(this);
        var text = self.find("option:selected").attr("title");
        if(text && text == 'Y') {
         $("#observ_cond_transf").prop("readOnly", false)
        } else {
          $("#observ_cond_transf").prop("readOnly", true).val("")
        }
    });
    
    $(".should-type").click(function(){
      var that = $(this);
      var i = that.data('index');
      if (that.is(":checked")) {
        $("#observacion"+i).prop("readOnly", false)
      } else {
        $("#observacion"+i).val("").prop("readOnly", true)
      }
    });
    
    $(".should-be-corrected").blur(function(e){
        var self = $(this);
        if ($.trim(self.val())) self.css("border","inherit");
    });
    
});


function canSubmit() {
  var proceed = true;
  
  $(".observacion").each(function() {
    var $self = $(this);
    var i = $self.data('index');
    var message = $self.data('message');
    var $_textBox = $("#observacion"+i);
    if ( $self.is(":checked") && !$.trim($_textBox.val()) ) {
      parent.CBMSG.error(message ? message : "Cuando selecciona 'Otro', el campo de observación es obligatorio!", {
        btnTxt: "Ok",
        cb: function(r){
          if(r=='Ok') {
            $_textBox.focus().css("border", "1px solid #ff0000").prop("readOnly",false);
          }
        }
      });
      proceed = false;
      return false;  
    }else  {proceed = true;}
  });

  var text = $("#cond_transf").find("option:selected").attr("title");
  if( text && text == 'Y' && !$.trim($("#observ_cond_transf").val()) ) {
    proceed = false;
    parent.CBMSG.error("Por favor indique las otras condiciones!", {
        btnTxt: "Ok",
        cb: function(r){
          if(r=='Ok') {
            $("#observ_cond_transf").focus().css("border", "1px solid #ff0000").prop("readOnly",false);
          }
        }
    });
  }
  return proceed;
}

function signosVitales() {
   var url = encodeURI('../expediente3.0/exp_triage.jsp?modeSec=add&mode=<%=mode%>&fg=SV&seccion=77&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=agregar&desc=SIGNO VITALES&from=traslado&index='+i+'&fecha_nacimiento=<%=pacData.getColValue("fn")%>&codigo_paciente=<%=pacData.getColValue("codigo")%>');
    abrir_ventana(url);
}
</script>
</head>

<body class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">

    <div class="headerform">
    <table cellspacing="0" class="table pull-right table-striped table-custom-1">
        <tr>
            <td>
                <%=fb.button("imprimir","imprimir",false,false,null,null,"onClick=\"javascript:printCartaTraslado()\"")%>
            </td>
        </tr>
    </table>
    </div>
    
    <%fb = new FormBean2("form002",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
    <%=fb.formStart(true)%>
    <%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
    <%=fb.hidden("tab","0")%>
    <%=fb.hidden("baction","")%>
    <%=fb.hidden("mode",mode)%>
    <%=fb.hidden("modeSec",modeSec)%>
    <%=fb.hidden("seccion",seccion)%>
    <%=fb.hidden("dob","")%>
    <%=fb.hidden("codPac","")%>
    <%=fb.hidden("pacId",pacId)%>
    <%=fb.hidden("noAdmision",noAdmision)%>
    <%=fb.hidden("desc",desc)%>
    <%=fb.hidden("cds",cds)%>
    <%=fb.hidden("id_transf",cdoP.getColValue("id"))%>
    <%=fb.hidden("tipo_transf_params","2")%>
    <%=fb.hidden("tipo_transf_paramsM","")%>
    <%=fb.hidden("tipo",cdoP.getColValue("tipo"))%>
    <%=fb.hidden("type","")%>
    <%=fb.hidden("tipoSize",""+alTipos.size())%>
    <table cellspacing="0" class="table table-small-font table-bordered table-striped">
		  	<tr class="bg-headtabla">
		  		<td colspan="4">INFORMACIONES EXTRA DE LA TRANSFERENCIA</td>
		  	</tr>
			<tr class="TextRow01">
				<td>&Aacute;rea que solicita</td>
				<td><%=fb.select(ConMgr.getConnection(), "select codigo, descripcion from tbl_cds_centro_servicio where compania_unorg = "+compania+" order by descripcion ","area_solicita",cdoP.getColValue("cds_solicita"),false,false,0,"form-control input-sm",null,"",null,"S")%></td>
		  		<td>Transferido a</td>
		  		<td>
                <%//=fb.select(ConMgr.getConnection(), "select id, nombre from tbl_sal_centros_tranf where compania = "+compania+" order by nombre ","transf_a",cdoP.getColValue("transferido_a"),false,false,0,"form-control input-sm",null,"",null,"S")%>
                <%=fb.textBox("transf_a",cdoP.getColValue("transferido_a"),false,false,viewMode,35,200,"form-control input-sm",null,null)%>
                </td>
		  	</tr>
            
            <tr class="TextRow01">
				<td>Coordinador del Traslado</td>
				<td><%=fb.textBox("coordinador",cdoP.getColValue("coordinador"),false,false,viewMode,35,150,"form-control input-sm",null,null)%></td>
		  		<td>&Aacute;rea</td>
		  		<td><%=fb.select(ConMgr.getConnection(), "select codigo, descripcion from tbl_cds_centro_servicio where compania_unorg = "+compania+" order by descripcion ","area_coordinador",cdoP.getColValue("area_coordinador"),false,false,0,"form-control input-sm",null,"",null,"S")%></td>
		  	</tr>
            
			<tr class="TextRow01">
				<td>Responsable</td>
				<td><%=fb.textBox("acompaniante_transf",cdoP.getColValue("acompaniante_transf"),false,false,viewMode,35,150,"form-control input-sm",null,null)%></td>
		  		<td>Parentesco</td>
		  		<td><%=fb.select(ConMgr.getConnection(), "select codigo, descripcion from tbl_pla_parentesco order by descripcion ","parentesco_acompaniante",cdoP.getColValue("parentesco_acompaniante"),false,false,0,"form-control input-sm",null,"",null,"S")%></td>
		  	</tr>
			<tr class="TextRow01">
				<td colspan="4" class="controls form-inline">Condici&oacute;n en el momento del traslado:&nbsp;
				<%=fb.select(ConMgr.getConnection(), "select id, descripcion, es_otro from tbl_sal_transferencia_params where status = 'A' and tipo = 1 and compania = "+compania+" order by 1","cond_transf",cdoP.getColValue("cond_transf"),false,false,0,"form-control input-sm",null,"",null,"")%>
                &nbsp;&nbsp;&nbsp;
                <%=fb.textarea("observ_cond_transf", cdoP.getColValue("observ_cond_transf"), false, false, viewMode||cdoP.getColValue("observ_cond_transf"," ").trim().equals(""), 0, 1,0, "form-control input-sm should-be-corrected", "width:40%", "")%>
                
                &nbsp;&nbsp;&nbsp; 
                <button type="button" class="btn btn-inverse btn-sm" onclick="javascript:signosVitales()"><i class="fa fa-print fa-lg"></i> Signos Vitales</button>
			   </td>
		  	</tr>
			<tr class="bg-headtabla2">
				<td colspan="4">REQUERIMIENTOS/MOTIVOS DEL TRASLADO</td>
			</tr>
			<tr>
			  <td colspan="4">
              
              <table cellspacing="0" class="table table-small-font table-bordered table-striped">
                  <%
                  String gTipo = "";
                  for (int i = 0; i<alTipos.size(); i++){
                     CommonDataObject cdoT = (CommonDataObject) alTipos.get(i);
        
                     if (!gTipo.equals(cdoT.getColValue("tipo"))){%>   
                        <tr class="bg-headtabla pointer header" data-tipo="<%=cdoT.getColValue("tipo")%>">
                            <td width="10%" align="right">[<%=cdoT.getColValue("tipo")%>]&nbsp;</td>
                            <td width="90%" colspan="2"><%=cdoT.getColValue("tipo_desc")%></td>
                        </tr>
                     <%}%>
                     
                     <tr class="pointer det_<%=cdoT.getColValue("tipo")%>" style="display:none">
                        <td>&nbsp;</td>
                        <td>
                          <label class="pointer">
                      <%=fb.checkbox("id_trans_params"+i, cdoT.getColValue("id"), cdoT.getColValue("id").equals(cdoT.getColValue("id_trans_params")), viewMode, "should-type"+(cdoT.getColValue("es_otro","N").equalsIgnoreCase("Y")?" observacion":"") ,null,"",""," data-index="+i)%>
                          
                          <%=cdoT.getColValue("descripcion")%></label>
                        </td>
                        <td class="controls form-inline"><b>Observaci&oacute;n:</b>&nbsp;<%=fb.textarea("observacion"+i, cdoT.getColValue("observacion"), false, false, viewMode||cdoT.getColValue("observacion"," ").trim().equals(""), 0, 1,0, "form-control input-sm"+(cdoT.getColValue("es_otro","N").equalsIgnoreCase("Y")?" should-be-corrected":""), "width:60%", "")%></td>
                    </tr>
                    <%=fb.hidden("tipo"+i, cdoT.getColValue("tipo"))%>
                     
                  <% 
                    gTipo = cdoT.getColValue("tipo");
                  }
                  %>
              </table>
              
 
				</td>
			</tr>
            
            <tr class="TextRow01">
				<td>Personal del Traslado:</td>
				<td><%=fb.textBox("personal_translado",cdoP.getColValue("personal_translado"),false,false,viewMode,35,150,"form-control input-sm",null,null)%></td>
		  		<td>Proveedor:</td>
		  		<td>
                <%=fb.textBox("proveedor",cdoP.getColValue("proveedor"),false,false,viewMode,35,150,"form-control input-sm",null,null)%>
                </td>
		  	</tr>
            <tr class="TextRow01">
				<td colspan="4" class="controls form-inline">
                    Seguimiento al centro de traslado:&nbsp;&nbsp;&nbsp;
                    Fecha:
                     <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                        <jsp:param name="noOfDateTBox" value="1" />
                        <jsp:param name="clearOption" value="true" />
                        <jsp:param name="nameOfTBox1" value="fecha_seguimiento" />
                        <jsp:param name="valueOfTBox1" value="<%=cdoP.getColValue("fecha_seguimiento"," ")%>" />
                    </jsp:include>
                    Hora:
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                        <jsp:param name="noOfDateTBox" value="1" />
                        <jsp:param name="clearOption" value="true" />
                        <jsp:param name="format" value="hh12:mi:ss am" />
                        <jsp:param name="nameOfTBox1" value="hora_seguimiento" />
                        <jsp:param name="valueOfTBox1" value="<%=cdoP.getColValue("hora_seguimiento"," ")%>" />
                    </jsp:include>
                    Condici&oacute;n:<%=fb.textBox("condicion_seguimiento",cdoP.getColValue("condicion_seguimiento"),false,false,viewMode,35,150,"form-control input-sm",null,null)%>
                </td>
		  	</tr>
            
            
            
            </table>
            
            <div class="footerform" style="bottom:-11px !important">
                <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                    <tr>
                        <td>
                        <%=fb.hidden("saveOption","O")%>
                        <%=fb.submit("save","Guardar",true,viewMode,null,null,"")%>
                        </td>
                    </tr>
                </table>
           </div> 
            
            
	<%=fb.formEnd(true)%>
	</div>
</div>
</table>
</body>
</html>
<%
}//GET
else
{	
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
	String itemRemoved = "";
	int size = 0;
	
	ArrayList al2 = new ArrayList();	
	
	  if (baction.equals("Guardar")){
	    cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_cons_incap_transf");
		cdo.setWhereClause("tipo='"+request.getParameter("tipo")+"' and pac_id ="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and id = "+request.getParameter("id_transf"));
	   
		cdo.addColValue("OTRAS_CONDICIONES", request.getParameter("observ_cond_transf"));
		cdo.addColValue("FECHA_MODIFICACION",curDate);
		cdo.addColValue("USUARIO_MODIFICACION",userName);
		cdo.addColValue("TRANSFERIDO_A",request.getParameter("transf_a"));
		cdo.addColValue("CDS_SOLICITA",request.getParameter("area_solicita"));
		cdo.addColValue("FECHA_TRANSFERENCIA",curDate);
		cdo.addColValue("ACOMPANIANTE_TRANSF",request.getParameter("acompaniante_transf"));
		cdo.addColValue("PARENTESCO_ACOMPANIANTE",request.getParameter("parentesco_acompaniante"));
		cdo.addColValue("COND_TRANSF",request.getParameter("cond_transf"));
        
		cdo.addColValue("coordinador",request.getParameter("coordinador"));
		cdo.addColValue("area_coordinador",request.getParameter("area_coordinador"));
		cdo.addColValue("personal_translado",request.getParameter("personal_translado"));
		cdo.addColValue("proveedor",request.getParameter("proveedor"));
		cdo.addColValue("fecha_seguimiento",request.getParameter("fecha_seguimiento"));
		cdo.addColValue("hora_seguimiento",request.getParameter("hora_seguimiento"));
		cdo.addColValue("condicion_seguimiento",request.getParameter("condicion_seguimiento"));
		cdo.setAction("U");
		al2.add(cdo);
		SQLMgr.saveList(al2,true);
	}
		
		al.clear();
		
		if (request.getParameter("tipoSize") != null) size = Integer.parseInt(request.getParameter("tipoSize"));
		
		for (int i=0; i<size; i++)
		{
            if (request.getParameter("id_trans_params"+i) != null){
                CommonDataObject cdo2 = new CommonDataObject();
                cdo2.setTableName("tbl_sal_transf_det");
                            
                cdo2.setWhereClause("tipo='"+request.getParameter("tipo")+"' and id_transf ="+request.getParameter("id_transf"));
                
                cdo2.addColValue("id_transf",request.getParameter("id_transf"));
                cdo2.addColValue("tipo",request.getParameter("tipo"));
                cdo2.addColValue("tipo_transf_params", request.getParameter("tipo"+i));
                cdo2.addColValue("id_trans_params",request.getParameter("id_trans_params"+i));

                cdo2.addColValue("observacion",request.getParameter("observacion"+i));

                al.add(cdo2);
            } 
		} // for i

		if (baction.equalsIgnoreCase("Guardar"))
		{
			if (al.size() == 0)
			{
				cdo = new CommonDataObject();
				cdo.setTableName("tbl_sal_transf_det");
				cdo.setWhereClause("tipo='"+request.getParameter("tipo")+"' and id_transf ="+request.getParameter("id_transf"));
				cdo.setAction("I");
				al.add(cdo);
			}
            
            SQLMgr.insertList(al, true, true);
			if (SQLMgr.getErrCode().equals("1")) session.removeAttribute("iCdoP");
		}
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
function closeWindow(){
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&cds=<%=cds%>';
<%
}else throw new Exception(SQLMgr.getErrMsg());
%>

}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>