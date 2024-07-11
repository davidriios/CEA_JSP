<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.EscalaNorton"%>
<%@ page import="issi.expediente.DetalleEscalaNorton"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iMed" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ECMgr" scope="page" class="issi.expediente.EscalaNortonMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ECMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
EscalaNorton en = new EscalaNorton();

boolean viewMode = false;
boolean checkDefault = false;

int rowCount = 0;
String sql = "";
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fecha = request.getParameter("fecha");
String fg = request.getParameter("fg");
String id = request.getParameter("id");
String fp = request.getParameter("fp");
String desc = request.getParameter("desc");
String subTitle="ESCALA DE NORTON";
String key = "";
int size = 0;
int ValorLabel=0;  //Roberto

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cDate = cDateTime.substring(0,10);
String cTime = cDateTime.substring(10,22);
if (fecha == null) fecha = cDate;
if (fg == null) fg = "NO";
if (fp == null) fp = "";
if (mode == null || mode.trim().equals("")) mode = "add";
if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (id == null || id.trim().equals("")) id = "0";

if (mode.equalsIgnoreCase("view")||modeSec.equalsIgnoreCase("view")) viewMode = true;
/*if (CmnMgr.getCount("select count(*) from tbl_sal_escala_norton where pac_id  = "+pacId+" and secuencia = "+noAdmision+" and to_date(to_char(fecha,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+fecha+"','dd/mm/yyyy')") == 0){
if (!viewMode) mode = "add";
}else
{if(!viewMode || fecha.trim().equals(cDate))
{ 	mode ="edit"; viewMode = false;}}
*/

/*if((fecha.trim().equals(cDate) && !id.trim().equals("0") ))
{ 	modeSec ="edit"; if(!mode.equalsIgnoreCase("view"))viewMode = false;}
*/

if (fg.equalsIgnoreCase("BR")) subTitle = "ESCALA DE BRADEN";
else if (fg.equalsIgnoreCase("SG")) subTitle = "ESCALA SUSAN GIVENS";

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
		
		sql=" select x.* from (select usuario_recup,  to_char(fecha_recup,'dd/mm/yyyy')fecha_recup,  to_char(fecha,'dd/mm/yyyy')fecha, total,id,usuario_creacion as usuario,to_char(hora,'hh12:mi:ss am') as hora,usuario_modificacion as usuarioMod, to_char(fecha_modificacion,'dd/mm/yyyy')fechaMod, to_char(fecha_modificacion,'hh12:mi:ss am')horaMod,to_date(to_char(fecha,'dd/mm/yyyy')||' '||to_char(nvl(hora,fecha_creacion),'hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') f_hr from tbl_sal_escala_norton where pac_id  = "+pacId+" and secuencia =  "+noAdmision+" and tipo = '"+fg+"'  ) x order by f_hr desc";
		al3 = SQLMgr.getDataList(sql);

		if(!modeSec.trim().equals("add"))
		{	
			
		sql="select to_char(fecha,'dd/mm/yyyy') fecha, observacion, total ,to_char(hora,'hh12:mi:ss am')hora from tbl_sal_escala_norton where pac_id= "+pacId+" and secuencia= "+noAdmision+" and  id = "+id+" /* and  fecha(+)=to_date('"+fecha+"','dd/mm/yyyy')*/ ";
		en = (EscalaNorton) sbb.getSingleRowBean(ConMgr.getConnection(), sql, EscalaNorton.class);
		//System.out.println("Sql :: == "+sql);

			if (en == null)
			{
				en = new EscalaNorton();
				en.setFecha(fecha);
				en.setHora(cTime);
			}
		}else
		{
			en.setFecha(fecha);
            en.setHora(cTime);
		}



		sql=" select distinct a.codigo, a.descripcion,b.observacion from tbl_sal_concepto_norton a, tbl_sal_det_escala_norton b where a.tipo ='"+fg+"' and estado = 'A' and  a.codigo = b.cod_concepto(+) and  b.id(+)="+id+"/*and b.fecha(+)=to_date('"+fecha+"','dd/mm/yyyy')*/ order by a.codigo asc ";
System.out.println("Sql :: == "+sql);
		al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleEscalaNorton.class);

CommonDataObject cdoE = new CommonDataObject();
if(!id.trim().equalsIgnoreCase("0")){
    cdoE = SQLMgr.getData("select i.codigo, i.descripcion, ip.observacion from tbl_sal_intervencion i, tbl_sal_intervencion_paciente ip where i.estado = 'A' and i.tipo = '"+fg+"' and i.codigo = ip.cod_intervencion and ip.pac_id = "+pacId+" and ip.admision = "+noAdmision+" and ip.id_escala = "+id+" order by 1");
    
    if(cdoE == null) cdoE = new CommonDataObject();
}

%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<script>
document.title = '<%=subTitle%> - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){checkViewMode();}
function sumaEscala(){var total = 0;for (i=1;i<=parseInt(document.getElementById("size").value);i++){total = total + parseInt(document.getElementById("valor"+i).value);document.getElementById("total").value = total;document.getElementById("total2").value = total;<%if(fg.trim().equals("NO")){%>if (total >= 0 &&total<=12){document.getElementById("clasificacion").style.color='red';document.getElementById("clasificacion").innerHTML='ALTO RIESGO';document.getElementById("clasificacion2").style.color='red';document.getElementById("clasificacion2").innerHTML='ALTO RIESGO';}else if (total>=13&&total<=15){document.getElementById("clasificacion").style.color='orange';document.getElementById("clasificacion").innerHTML='PRECAUCION';document.getElementById("clasificacion2").style.color='orange';document.getElementById("clasificacion2").innerHTML='PRECAUCION';}else if (total>=16){document.getElementById("clasificacion").style.color='green';document.getElementById("clasificacion").innerHTML='NORMAL';document.getElementById("clasificacion2").style.color='green';document.getElementById("clasificacion2").innerHTML='NORMAL';}<%}else if(fg.trim().equals("BR")){%>
if (total < 16){
    document.getElementById("clasificacion").style.color='red';
    document.getElementById("clasificacion").innerHTML='ALTO RIESGO';
    document.getElementById("clasificacion2").style.color='red';
    document.getElementById("clasificacion2").innerHTML='ALTO RIESGO';
}else if (total >= 16 && total <= 18){
    document.getElementById("clasificacion").style.color='orange';document.getElementById("clasificacion").innerHTML='BAJO RIESGO';document.getElementById("clasificacion2").style.color='orange';document.getElementById("clasificacion2").innerHTML='BAJO RIESGO';
}else if (total > 18){
    document.getElementById("clasificacion").style.color='blue';document.getElementById("clasificacion").innerHTML='NO RIESGO';document.getElementById("clasificacion2").style.color='blue';document.getElementById("clasificacion2").innerHTML='NO RIESGO';
}
<%}else  if(fg.trim().equals("SG")){%>if (total>=0&&total<=5){document.getElementById("clasificacion").style.color='blue';document.getElementById("clasificacion").innerHTML='NORMAL';document.getElementById("clasificacion2").style.color='blue';document.getElementById("clasificacion2").innerHTML='NORMAL';}else if (total>=6){document.getElementById("clasificacion").style.color='orange';document.getElementById("clasificacion").innerHTML='PRECAUCION';document.getElementById("clasificacion2").style.color='orange';document.getElementById("clasificacion2").innerHTML='PRECAUCION';}<%}%>}}
function checkValor(x,y,z){document.getElementById("valor"+x).value = y;document.getElementById("cod_subconcepto"+x).value = z;sumaEscala();}
function verEscala(k){var fecha_e = eval('document.form0.fecha'+k).value ;var id = eval('document.form0.idx'+k).value ;window.location = '../expediente3.0/exp_escala_norton.jsp?mode=<%=mode%>&modeSec=view&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&fp=<%=fp%>&id='+id+'&fecha='+fecha_e+"&desc=<%=desc%>";}
function add(){window.location = '../expediente3.0/exp_escala_norton.jsp?mode=<%=mode%>&modeSec=add&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&fp=<%=fp%>&id=0&desc=<%=desc%>';}
function printEscala(option){
    var fecha = document.form0.fecha.value;
    var intCode = "<%=cdoE.getColValue("codigo","0")%>";
    var intDesc = "<%=cdoE.getColValue("descripcion","N/A")%>";
    var intObserv = "<%=cdoE.getColValue("observacion","N/A")%>";
    
    if(!option)abrir_ventana1('../expediente3.0/print_escala_norton.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&fg=<%=fg%>&id=<%=id%>&desc=<%=desc%>&fechaEscala='+fecha+'&int_code='+intCode+'&int_desc='+intDesc+'&int_observ='+intObserv);
    else abrir_ventana1('../expediente3.0/print_escala_norton.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&fg=<%=fg%>&id=&desc=<%=desc%>&fechaEscala='+fecha+'&int_code='+intCode+'&int_desc='+intDesc+'&int_observ='+intObserv);
}
function printEscalaTodo(){
    var fecha = document.form0.fecha.value;
    abrir_ventana1('../expediente3.0/print_escala_norton.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>');
}

$(function(){
   $("#__intervencion").click(function(e){
       var total = $("#total2").val() || 0;
       <%if(request.getParameter("showIntervention")!=null && request.getParameter("showIntervention").equalsIgnoreCase("Y")){%>
            var showIntervention = true;
       <%} else {%>
            var showIntervention = false;
       <%}%>
       var url = '../expediente3.0/exp_intervencion_list.jsp?fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id_escala=<%=id%>&total='+total;
       <%if(modeSec.equalsIgnoreCase("view")){%>
          if(showIntervention){
            <%if(fp.trim().equals("SV")){%>top.showInterv(url, {screwTheUser:true});<%}else{%>parent.showInterv(url, {screwTheUser:true});<%}%>
          }else{
            url += '&mode=<%=modeSec%>';
            <%if(fp.trim().equals("SV")){%>top.showInterv(url, {screwTheUser:false});<%}else{%>parent.showInterv(url, {screwTheUser:false});<%}%>
          }
       <%} else {%>
         <%if(fp.trim().equals("SV")){%>top.showInterv(url, {screwTheUser:true});<%}else{%>parent.showInterv(url, {screwTheUser:true});<%}%>
      <%}%>
   });
   
   <%if(request.getParameter("showIntervention")!=null && request.getParameter("showIntervention").equalsIgnoreCase("Y")){%>
     $("#__intervencion").click();
   <%}%>
   
});

function printEscalaXhora(){
  var fecha = $("#rpt_fecha").val();
  if (fecha) {
    abrir_ventana1('../cellbyteWV/report_container.jsp?reportName=expediente/rpt_escalas_dolor.rptdesign&pCtrlHeader=true&tipo=<%=fg%>&tipo_desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha='+fecha)
  }
}

function verHistorial() {
  $("#hist_container").toggle();
}

function consultar(){abrir_ventana1('../expediente3.0/list_evaluacion_dolor.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>');}
</script>
</head>
<body class="body-form">
<div class="row">

<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("medSize","")%>
<%=fb.hidden("medLastLineNo","")%>
<%=fb.hidden("id",""+id)%>
<%=fb.hidden("fg",""+fg)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("fp",""+fp)%>
<%if(!fp.trim().equals("SV")){%>
<div class="headerform">
<table cellspacing="0" class="table pull-right table-striped table-custom-2">
<tr>
<td class="controls form-inline">
  <button type="button" class="btn btn-inverse btn-sm" onClick="consultar()">
    <i class="fa fa-search fa-printico"></i> <b>Consultar</b>
  </button>
      
<%if(!mode.equals("view")){%>
    <button type="button" class="btn btn-inverse btn-sm" onClick="add()">
        <i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
    </button>
<%}%>

<%if(!id.trim().equals("0")){%>
 <button type="button" class="btn btn-inverse btn-sm" onClick="printEscala()"><i class="fa fa-print fa-printico"></i> <b>Imprimir</b></button>
 <%}%>

<%if(al3.size() > 0){%>
 <button type="button" class="btn btn-inverse btn-sm" onClick="printEscala(1)"><i class="fa fa-print fa-printico"></i> <b>Imprimir Todas</b></button>
<%}%>

<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
<jsp:param name="noOfDateTBox" value="1" />
<jsp:param name="clearOption" value="true" />
<jsp:param name="nameOfTBox1" value="rpt_fecha" />
<jsp:param name="valueOfTBox1" value="<%=cDate%>" />
</jsp:include>
<button type="button" class="btn btn-inverse btn-sm" onClick="printEscalaXhora()"><i class="fa fa-print fa-printico"></i> <b>Por Hora</b></button>
 <button type="button" class="btn btn-inverse btn-sm" onClick="verHistorial()">
    <i class="fa fa-eye fa-printico"></i> <b>Historial</b>
  </button>
</td>
</tr>
</table> 

<div class="table-wrapper" id="hist_container" style="display:none">  
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>                                       
<tr><th colspan="6" class="bg-headtabla"><cellbytelabel>Listado de Evaluaciones</cellbytelabel></th></tr>
<tr class="bg-headtabla2">
    <th><cellbytelabel>Fecha</cellbytelabel></th>
    <th><cellbytelabel>Hora</cellbytelabel></th>
    <th><cellbytelabel>Total</cellbytelabel></th>
    <th><cellbytelabel>Creado Por</cellbytelabel></th>
    <th><cellbytelabel>Modif. por</cellbytelabel></th>
    <th><cellbytelabel>Fecha/Hora Mod</cellbytelabel>.</th>
    <th><cellbytelabel>Fecha Recup</cellbytelabel>.</th>
</tr>
<tbody>
<%

for (int i=1; i<=al3.size(); i++)
{
	cdo = (CommonDataObject) al3.get(i-1);
	%>

		<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("idx"+i,cdo.getColValue("id"))%>


		<tr class="pointer" onClick="javascript:verEscala(<%=i%>)">
					
			<td><%=cdo.getColValue("fecha")%></td>
            <td><%=cdo.getColValue("hora")%></td>
            <td align="center"><%=cdo.getColValue("total")%></td>
            <td><%=cdo.getColValue("usuario")%></td>
            <td><%=cdo.getColValue("usuarioMod")%></td>
            <td><%=cdo.getColValue("fechaMod")%>/<%=cdo.getColValue("horaMod")%></td>
            <td><%=cdo.getColValue("fecha_recup")%></td>
			
		</tr>
<%
}
%>
</tbody>
</table>
</div>           
 </div> 
<%}%>
<table cellspacing="0" class="table table-small-font table-bordered table-striped"> 
<tr>
    <td><cellbytelabel id="4">Fecha</cellbytelabel>:</td>
    <td class="controls form-inline"><jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
        <jsp:param name="noOfDateTBox" value="1" />
        <jsp:param name="clearOption" value="true" />
        <jsp:param name="nameOfTBox1" value="fecha" />
        <jsp:param name="valueOfTBox1" value="<%=en.getFecha()%>" />
        <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
        </jsp:include> </td>
         <td><cellbytelabel id="6">Hora</cellbytelabel></td>
         <td class="controls form-inline">
         <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
        <jsp:param name="noOfDateTBox" value="1" />
        <jsp:param name="clearOption" value="true" />
        <jsp:param name="nameOfTBox1" value="hora" />
        <jsp:param name="valueOfTBox1" value="<%=en.getHora()%>" />
        <jsp:param name="format" value="hh12:mi:ss am"/>
        <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
        </jsp:include>
        
        <%if(!modeSec.trim().equalsIgnoreCase("add") && (fg.trim().equals("BR") || fg.trim().equals("SG"))){%>
            <div class="pull-right"><button type="button" class="btn btn-inverse" id="__intervencion" data-fg="<%=fg%>">Intervenciones</button></td>
        <%}%>
        
        
        </td>
</tr>
<tr>
    <td colspan="4"><cellbytelabel id="7">Observaci&oacute;n</cellbytelabel><%=fb.textarea("observacion",en.getObservacion(),false,false,viewMode,70,0,2000,"form-control input-sm","width:100%",null)%></td>
</tr>
</table>
			
<table cellspacing="0" class="table table-small-font table-bordered table-striped">                 
    <tr>
        <td>&nbsp;</td>
        <td align="right" class="controls form-inline"><cellbytelabel id="5">Total</cellbytelabel>:<%=fb.textBox("total","",false,false,true,5,0,"form-control input-sm",null,null)%></td>
        <td><b><label id="clasificacion" style="color:green">HOLA</label></b></td>
    </tr>
    <tr class="bg-headtabla2" align="center">
        <th><cellbytelabel id="8">Factor a Evaluar</cellbytelabel></th>
        <th><cellbytelabel id="9">Escala</cellbytelabel></th>
        <th><cellbytelabel id="10">Observaci&oacute;n</cellbytelabel></th>
    </tr>
    <%if(fg.trim().equals("SG")){%>
    <tr class="bg-headtabla">
            <td colspan="3"><cellbytelabel id="11">SIGNOS CONDUCTUALES</cellbytelabel></td>
    </tr>
    <%}%>
		
    <tr class="TextRow01">
       <td colspan="3">
         <table width="100%" cellpadding="1" cellspacing="0" class="table table-small-font table-bordered table-striped">
        <%for (int i = 1; i <= al.size(); i++){
                String color = "TextRow02";
                if (i % 2 == 0) color = "TextRow01";

                key = al.get(i - 1).toString();
                DetalleEscalaNorton co = (DetalleEscalaNorton) al.get(i - 1);
        %>
			<%=fb.hidden("key"+i,key)%>
		<%if(fg.trim().equals("SG")&& i==7){%>
		<tr class="bg-headtabla">
				<td colspan="3"><cellbytelabel id="12">SIGNOS FISIOL&Oacute;GICOS</cellbytelabel></td>
		</tr>
		<%}%>
			<tr>
				<td align="left" width="20%"><%=co.getDescripcion()%></td>
				<td width="20%">
<!-- ======================================= INICIO LOOP ESCALA  ================================================ -->
				<table width="100%" border="0" cellpadding="0" cellspacing="0" class="table table-small-font table-bordered table-striped">
				<%
					sql = "select b.observacion,a.codigo,a.descripcion,a.secuencia,a.valor,nvl(b.valor,-1) as escala from tbl_sal_det_escala_norton b, tbl_sal_det_concepto_norton a where  a.codigo = b.COD_CONCEPTO(+) and a.secuencia = b.COD_SUBCONCEPTO(+) and a.tipo = '"+fg+"' and a.estado ='A' and a.codigo="+co.getCodigo()+" and b.id(+)= "+id+" /*and b.pac_id(+)="+pacId+" AND b.fecha(+)=to_date('"+fecha+"','dd/mm/yyyy')*/ ORDER BY a.valor DESC ";
					al2 = SQLMgr.getDataList(sql);
					String cod_subconcepto = "";
					String valor = "";
					for (int j=0; j<al2.size(); j++){
					cdo = (CommonDataObject) al2.get(j);

					if(j==0){

					cod_subconcepto = cdo.getColValue("secuencia");
					if (viewMode)
					{
						checkDefault=false;
						valor = cdo.getColValue("escala");
					}else
					{

						/*if(fg.equalsIgnoreCase("SG"))checkDefault=false;
						else */checkDefault=true;
						valor = cdo.getColValue("valor");
					}

					} else { checkDefault=false; }

					if(cdo.getColValue("escala").equalsIgnoreCase(cdo.getColValue("valor"))){
					checkDefault=true;
					cod_subconcepto = cdo.getColValue("secuencia");
					valor = cdo.getColValue("valor");
					}

				if(valor.equalsIgnoreCase("-1"))valor="0";

				%>
					<tr>
						<td width="5%" valign="top" >
						<%=fb.radio("secuencia"+i, cdo.getColValue("valor"), checkDefault, viewMode, false, "", "", "onClick=\"javascript:checkValor('"+i+"','"+cdo.getColValue("valor")+"','"+cdo.getColValue("secuencia")+"')  \" ")%></td>
						<td valign="top"><%=cdo.getColValue("descripcion")%></td>
						<td width="5%" align="right" valign="top"><%=cdo.getColValue("valor")%></td>
					</tr>
				<% } %>
				</table>

				<%=fb.hidden("cod_concepto"+i,co.getCodigo())%>
				<%=fb.hidden("cod_subconcepto"+i,cod_subconcepto)%>
				<%=fb.hidden("valor"+i,valor)%>

<!-- ======================================= FIN LOOP ESCALA  ================================================ --></td>
				<td width="25%"><%=fb.textarea("observacion"+i,co.getObservacion(),false,false,viewMode,50,0,2000,"form-control input-sm","width:100%",null)%></td>
				</tr>
<%
}
%>
				</table>				
	</td>
</tr>

			<tr class="TextRow02">
				<td>&nbsp;</td>
				<td align="right" class="controls form-inline"><cellbytelabel id="5">Total</cellbytelabel>:<%=fb.textBox("total2","",false,false,true,5,"form-control input-sm",null,null)%></td>
				<td><b><label id="clasificacion2" style="color:green">HOLA</label></b></td>

				</tr>

			<div class="footerform"><table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
<tr>
    <td>
        <%=fb.submit("save","Guardar",false,viewMode,"",null,"")%>
        <input type="hidden" name="saveOption" value="O">
        <button type="button" class="btn btn-inverse btn-sm" onClick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
    </tr>
    </table> </div> 
			
			<script type="text/javascript">sumaEscala();</script>
		</td>
	</tr>
	</table>
	<%=fb.formEnd(true)%>
</div>
</div>
</body>
</html>
<%
}//fin GET
else
{
	
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	size = Integer.parseInt(request.getParameter("size"));
	fecha = request.getParameter("fecha");
	ArrayList list = new ArrayList();
    String totalEscala="";
	EscalaNorton eno = new EscalaNorton();
	//eno.setCodigoPaciente(request.getParameter("codPac"));
	//eno.setFechaNacimiento(request.getParameter("dob"));
	eno.setSecuencia(request.getParameter("noAdmision"));
	eno.setFecha(request.getParameter("fecha"));
	eno.setHora(request.getParameter("hora"));
	eno.setPacId(request.getParameter("pacId"));
	eno.setId(request.getParameter("id"));
	eno.setTipo(request.getParameter("fg"));
	
	eno.setFechaCreacion(cDateTime);
	eno.setFechaModificacion(cDateTime);
	eno.setUsuarioCreacion((String) session.getAttribute("_userName"));
	eno.setUsuarioModificacion((String) session.getAttribute("_userName"));
	eno.setTotal(request.getParameter("total"));
	eno.setObservacion(request.getParameter("observacion"));
	totalEscala = request.getParameter("total");
HashDet.clear();
for (int i=1; i<=size; i++)
{
			DetalleEscalaNorton dre = new DetalleEscalaNorton();

			//dre.setFechaNacimiento(request.getParameter("dob"));
			//dre.setCodigoPaciente(request.getParameter("codPac"));
			//dre.setSecuencia(request.getParameter("noAdmision"));
			//dre.setFecha(request.getParameter("fecha"));
			dre.setCodConcepto(request.getParameter("cod_concepto"+i));
			dre.setCodSubconcepto(request.getParameter("cod_subconcepto"+i));
			dre.setValor(request.getParameter("valor"+i));
			dre.setAplicar("S");
			//dre.setPacId(request.getParameter("pacId"));
			dre.setObservacion(request.getParameter("observacion"+i));

			try {
			HashDet.put(request.getParameter("key"+i), dre);
			}
			catch(Exception e)
			{ System.err.println(e.getMessage()); }

			list.add(dre);
}
	eno.setDetalleEscalaNorton(list);
	if (modeSec.equalsIgnoreCase("add"))
	{
		ECMgr.add(eno);
		id = ECMgr.getPkColValue("id");
	}
	else if (modeSec.equalsIgnoreCase("edit"))
	{
		id = request.getParameter("id");
		ECMgr.update(eno);
	}

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (ECMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ECMgr.getErrMsg()%>');
	if(parent.window.setValEscala)parent.window.setValEscala(<%=totalEscala%>);
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente3.0/exp_escala_norton.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/exp_escala_norton.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%	} %>
<%
	if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	parent.doRedirect(0);
<%
	}
} else throw new Exception(ECMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>&showIntervention=Y';
}
function editMode()
{
window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&mode=<%=mode%>&modeSec=view&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha=<%=fecha%>&id=<%=id%>&fg=<%=fg%>&desc=<%=desc%>&fp=<%=fp%>&showIntervention=Y';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

