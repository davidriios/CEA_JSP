<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htdesc" scope="session" class="java.util.Hashtable"/>
<%

SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CommonDataObject desc= new CommonDataObject();
String sql="";
String key="";
String mode = request.getParameter("mode");
String empId= request.getParameter("empId");
String prov=request.getParameter("prov");
String sig=request.getParameter("sig");
String tom=request.getParameter("tom");
String asi=request.getParameter("asi");
String num_empleado=request.getParameter("num");
String grupo=request.getParameter("grp");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
if(fp==null) fp = "ausencia_rrhh";
if(fg==null) fg = "";
ArrayList al= new ArrayList();
String change= request.getParameter("change");
int lineNo = 0;
//String fecha_inicial=
int desclastLineNo =0;
boolean viewMode = false;
if(mode == null) mode = "add"; 
if(mode.equals("view")) viewMode = true;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");


if(request.getParameter("desclastLineNo")!=null && ! request.getParameter("desclastLineNo").equals(""))
desclastLineNo=Integer.parseInt(request.getParameter("desclastLineNo"));
else desclastLineNo=0;

if (request.getMethod().equalsIgnoreCase("GET"))
{			
if(change==null)
{
		htdesc.clear();
sql = "select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.tipo_trx, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.secuencia, a.motivo_falta, c.descripcion motivo_falta_desc, to_char(a.hora_entrada, 'hh12:mi am') hora_entrada, to_char(a.fecha_salida, 'dd/mm/yyyy') fecha_salida, to_char(a.hora_salida, 'hh12:mi am') hora_salida, a.comentario, a.accion, a.anio_dev, a.mes_dev, a.quincena_dev, a.anio_des, a.mes_des, a.quincena_des, a.cod_planilla_des, a.estado_dev, to_char(a.fecha_dev, 'dd/mm/yyyy') fecha_dev, a.usuario_creacion, to_char(a.fecha_creacion, 'dd/mm/yyyy hh24:mi:ss') fecha_creacion, a.usuario_modificacion, to_char(a.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.cantidad, a.vobo_estado, a.vobo_usuario, to_char(a.vobo_fecha, 'dd/mm/yyyy') vobo_fecha, b.emp_id, nvl(b.rata_hora, 0) rata_hora, d.nombre cod_planilla_des_desc, nvl(a.monto, 0) monto, a.tiempo from tbl_pla_aus_y_tard a, tbl_pla_empleado b, tbl_pla_motivo_falta c, tbl_pla_planilla d where a.compania = b.compania and a.emp_id = b.emp_id and a.accion IN ('DS','DV','ND') AND a.estado_des = 'PE' and a.motivo_falta = c.codigo(+) and a.compania = d.compania and a.cod_planilla_des = d.cod_planilla and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;

	al=SQLMgr.getDataList(sql);
	for(int h=0;h<al.size();h++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(h);
		cdo.setKey(h);
		cdo.setAction("U");
		htdesc.put(cdo.getKey(),cdo);
	}
}

%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title="Registro de Tran. Ausencias y Tardanzas - Agregar - "+document.title;

function doAction(){
	setEmpleadoInfo('form');
	var size = <%=htdesc.size()%>;
	if(size>0){
		var x = getDBData('<%=request.getContextPath()%>', 'getAnioPlanilla(<%=(String) session.getAttribute("_companyId")%>)','dual','','');
		var arr_cursor = new Array();
		if(x!='' && x != 'undefined'){
			arr_cursor = splitCols(x);
			for(i=0;i<size;i++){
				if(eval('document.form.anio_des'+i).value == '') eval('document.form.anio_des'+i).value = arr_cursor[0];
				if(eval('document.form.quincena_des'+i).value == '') eval('document.form.quincena_des'+i).value = arr_cursor[1];
			}
		}
	}
}
function tipo(codeField, descField){abrir_ventana1('../rhplanilla/list_tipo_transaccion.jsp?fp=registro&codeField='+codeField+'&descField='+descField);}
function setTipoTrxValues(i){
	var fecha = eval('document.form.fecha'+i).value;
	var tipo_trx = eval('document.form.tipo_trx'+i).value;
	var emp_id = eval('document.form.empId').value;
	eval('document.form.hora_entrada'+i).value 		= '';
	eval('document.form.hora_salida'+i).value = '';
	if(emp_id !=''){
	if (tipo_trx == 2 || tipo_trx == 3){
		eval('document.form.fecha_salida'+i).value = fecha;
		var x = getDBData('<%=request.getContextPath()%>','nvl(to_char(h.hora_gracia_entrada, \'hh12:mi am\'), \' \'), nvl(to_char(h.hora_salida, \'hh12:mi am\'), \' \')','tbl_pla_horario_trab h, tbl_pla_empleado e','h.codigo = e.horario and h.compania = e.compania and e.emp_id = '+emp_id+' and e.compania = <%=(String) session.getAttribute("_companyId")%>','');
		var arr_cursor = new Array();
		if(x!=''){
			arr_cursor = splitCols(x);
			if(arr_cursor[0]!=' ') eval('document.form.hora_entrada'+i).value	= arr_cursor[0];
			if(arr_cursor[1]!=' ') eval('document.form.hora_salida'+i).value	= arr_cursor[1];
		}
	}
	}
}
function addMotivo(index)
{
	var tiempo = eval('document.form.tiempo'+index).value;
	var rata_hora = eval('document.form.rataHora').value;	
	if(tiempo!='')eval('document.form.monto'+index).value = Math.round(parseFloat(tiempo) * parseFloat(rata_hora)*100)/100;
    abrir_ventana1("../common/search_motivo_falta.jsp?fp=ausencia_rrhh&index="+index);
}
function cambioValue(index)
{
	var tiempo = eval('document.form.tiempo'+index).value;
	var rata_hora = eval('document.form.rataHora').value;
	eval('document.form.monto'+index).value = Math.round(parseFloat(tiempo) * parseFloat(rata_hora)*100)/100;
}
function motivoFalta(i){
	var fecha = eval('document.form.fecha'+i).value;
	var fecha_salida = eval('document.form.fecha_salida'+i).value;
	var hora_entrada = eval('document.form.hora_entrada'+i).value;
	var hora_salida = eval('document.form.hora_salida'+i).value;
	var tipo_trx = eval('document.form.tipo_trx'+i).value;
	var emp_id = eval('document.form.empId'+i).value;
	var accion = eval('document.form.accion'+i).value;
	var motivo_falta = eval('document.form.motivo_falta'+i).value;
	var tiempo = eval('document.form.tiempo'+i).value;
	var rata_hora = eval('document.form.rataHora').value;
	var total = 0.00, v_horas_dias = 0.00;
	if(emp_id!=''){
	var x = getDBData('<%=request.getContextPath()%>','round((to_date(\''+hora_entrada+'\',\'hh12:mi am\') - to_date(to_char(h.hora_entrada, \'hh12:mi am\'), \'hh12:mi am\'))*24, 2) + round((to_date(to_char(h.hora_salida, \'hh12:mi am\'), \'hh12:mi am\') - to_date(\''+hora_salida+'\',\'hh12:mi am\'))*24, 2), h.cant_horas','tbl_pla_horario_trab h, tbl_pla_empleado e', 'h.codigo = e.horario and h.compania = e.compania and e.emp_id = '+emp_id+' and e.compania = <%=(String) session.getAttribute("_companyId")%>','');
	var arr_cursor = new Array();
	if(x!=''){
		arr_cursor = splitCols(x);
		total	= arr_cursor[0];
		v_horas_dias	= arr_cursor[1];
	}			
	}
	if (accion == 'DS'){// DESCONTAR
		eval('document.form.anio_des'+i).readonly = false;
		eval('document.form.quincena_des'+i).readonly = false;
		eval('document.form.estado_des'+i).readonly = false;
		eval('document.form.fecha_des'+i).readonly = false;
		eval('document.form.tiempo'+i).readonly = false;
		eval('document.form.monto'+i).readonly = false;
		
		if (motivo_falta == 10 || motivo_falta == 11){// OMISION DE ENTRADA(10) / SALIDA(11)
			eval('document.form.tiempo'+i).value = tiempo;
			eval('document.form.monto'+i).value = parseFloat(tiempo) * parseFloat(rata_hora);
		} else {
			if (tipo_trx = 2 &&  fecha != '' && hora_entrada != '' && fecha_salida != '' && hora_salida != ''){
				eval('document.form.tiempo'+i).value = total;
				eval('document.form.monto'+i).value = total * rata_hora;
			} else if(tipo_trx == 1){
				eval('document.form.tiempo'+i).value = v_horas_dias;
				eval('document.form.monto'+i).value = v_horas_dias * rata_hora;
			}
		}
	} else {
		if (accion == 'DV'){ //DEVOLVER
			eval('document.form.anio_des'+i).readonly = false;
			eval('document.form.quincena_des'+i).readonly = false;
			eval('document.form.estado_des'+i).readonly = false;
			eval('document.form.fecha_des'+i).readonly = false;
			eval('document.form.tiempo'+i).readonly = false;
			eval('document.form.monto'+i).readonly = false;

			if (motivo_falta == 10 || motivo_falta == 11){
				eval('document.form.tiempo'+i).value = tiempo;
			} else {
				if (tipo_trx == 2 && fecha != '' && hora_entrada != '' && fecha_salida != '' && hora_salida != ''){
					eval('document.form.tiempo'+i).value = total;
					eval('document.form.monto'+i).value = total * rata_hora;
				} else if (tipo_trx == 1){
					eval('document.form.tiempo'+i).value = v_horas_dias;
					eval('document.form.monto'+i).value = v_horas_dias * rata_hora;
				}
			}
		} else {
			eval('document.form.anio_des'+i).readonly = false;
			eval('document.form.quincena_des'+i).readonly = false;
			eval('document.form.estado_des'+i).readonly = false;
			eval('document.form.fecha_des'+i).readonly = false;
			eval('document.form.tiempo'+i).readonly = false;
			eval('document.form.monto'+i).readonly = false;
		}
	}
}

function showPlanillaList(i){abrir_ventana('../rhplanilla/planilla_list.jsp?fp=ausencia_rrhh&id='+i);}
function chkValue(i){
	var cantidad = eval('document.form.tiempo'+i).value;
	var monto_unitario = eval('document.form.monto'+i).value;
	if(monto_unitario==''||monto_unitario=='0') monto_unitario = document.form.rataHora.value;
	//eval('document.form.monto_unitario'+i).value = document.form.rataHora.value;
	var x = 0;
	cantidad = parseFloat(cantidad);
	monto_unitario = parseFloat(monto_unitario);
	if(isNaN(cantidad)){
		alert('Introduzca valores Numéricos!');
		eval('document.form.cantidad'+i).value = '';
		x++;
	} else if(isNaN(monto_unitario)){
		alert('Introduzca valores Numéricos!');
		eval('document.form.monto_unitario'+i).value = '';
		x++;
	}

	if(x==0){
		eval('document.form.monto'+i).value = parseFloat(cantidad) * parseFloat(monto_unitario);
		return true;
	}
	else return false;
	eval('document.form.monto'+i).value = parseFloat(cantidad) * parseFloat(monto_unitario);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REGISTRO DE TRANSACIONES AUSENCIAS Y TARDANZAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0"> 
<tr> 
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">
			<tr class="TextRow01">
                <td colspan="4">
				<jsp:include page="../common/empleado.jsp" flush="true">
				<jsp:param name="empId" value="<%=empId%>"></jsp:param>
				<jsp:param name="fp" value="reg_trans"></jsp:param>
				<jsp:param name="mode" value="view"></jsp:param>
				</jsp:include>
                </td>
              </tr>

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
	<%fb = new FormBean("form",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
	<%=fb.hidden("empId",empId)%>
	<%=fb.hidden("keySize",""+htdesc.size())%>
	<%=fb.hidden("provincia","")%>
	<%=fb.hidden("sigla","")%>
	<%=fb.hidden("tomo","")%>
	<%=fb.hidden("asiento","")%>
	<%=fb.hidden("baction","")%>
  	<%=fb.hidden("num_empleado","")%>
	<%=fb.hidden("grupo","")%>
	<%=fb.hidden("rataHora","")%>
	<%=fb.hidden("fp",fp)%>
	<%=fb.hidden("fg",fg)%>
	<tr class="TextRow02">
		<td colspan="4">&nbsp;</td>
	</tr>	
	<tr class="TextHeader">
		<td colspan="3">&nbsp;Registro de Transacciones de Ausencias y Tardanzas</td>
		<td colspan="1" align="right"><%=fb.submit("btnagregar","+",false,false)%></td>
	</tr>
	<tr>
    <td colspan="4">
		<table width="100%">
<%
  String codigo="0"; 						
  if(htdesc.size()>0)
  al=CmnMgr.reverseRecords(htdesc);
  for (int i=0; i<al.size(); i++)
  {
		key = al.get(i).toString();
		CommonDataObject cdos = (CommonDataObject) htdesc.get(key);
		String style = (cdos.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";
		String color = "";
		String fecha = "fecha"+i;
		String fecha_salida = "fecha_salida"+i;
		String fecha_des = "fecha_des"+i;
		String hora_entrada = "hora_entrada"+i;
		String hora_salida = "hora_salida"+i;
		if (i%2 == 0) color = "TextRow02";
		else color = "TextRow01";
		boolean readonly = true;
	%>
	<%=fb.hidden("remove"+i,"")%>
	<%=fb.hidden("action"+i,cdos.getAction())%>
	<%=fb.hidden("key"+i,cdos.getKey())%>
	<%=fb.hidden("empId"+i, cdos.getColValue("emp_id"))%>
 	<%=fb.hidden("provincia"+i, cdos.getColValue("provincia"))%>
 	<%=fb.hidden("sigla"+i, cdos.getColValue("sigla"))%>
  	<%=fb.hidden("tomo"+i, cdos.getColValue("tomo"))%>
  	<%=fb.hidden("asiento"+i, cdos.getColValue("asiento"))%>
  	<%=fb.hidden("rata_hora"+i, cdos.getColValue("rata_hora"))%>
	<%=fb.hidden("cantidad"+i, cdos.getColValue("cantidad"))%>
	<%=fb.hidden("fecha_creacion"+i, cdos.getColValue("fecha_creacion"))%>
	<%=fb.hidden("usuario_creacion"+i, cdos.getColValue("usuario_creacion"))%>
	
<%if(cdos.getAction().equalsIgnoreCase("D")){%>
			  <%=fb.hidden("secuencia"+i, cdos.getColValue("secuencia"))%>
			  <%}if(!cdos.getAction().equalsIgnoreCase("D")){%>
<tr class="TextHeader02" <%=style%>>
    <td width="3%" align="center">Sec.</td>
    <td width="7%" align="center">Tipo Trx.</td>
    <td width="8%" align="center">Fecha</td>
    <td width="8%" align="center">Hora Entrada</td>
    <td width="8%" align="center">Fecha Salida</td>
    <td width="8%" align="center">Hora Salida</td>
    <td width="5%" align="center">Tiempo</td>
    <td width="8%" align="center">Acci&oacute;n</td>
    <td width="20%" align="center">Motivo Falta</td>
    <td width="5%" align="center">Monto</td>
    <td width="2%" align="center">&nbsp;</td>
  </tr>
  <tr class="<%=color%>" <%=style%> align="center">
    <td><%=fb.intBox("secuencia"+i,cdos.getColValue("secuencia"),false,false,true,2,3,"Text10",null,"")%></td>	
    <td><%=fb.select("tipo_trx"+i,"1=Ausencia,2=Tardanza",cdos.getColValue("tipo_trx"),false,false,0,"Text10",null,"onChange=\"javascript:setTipoTrxValues("+i+")\"")%></td>
    <td>
      <jsp:include page="../common/calendar.jsp" flush="true">
      <jsp:param name="noOfDateTBox" value="1" />
      <jsp:param name="clearOption" value="true" />
      <jsp:param name="nameOfTBox1" value="<%=fecha%>"/>					 	
      <jsp:param name="valueOfTBox1" value="<%=(cdos.getColValue("fecha")==null)?fecha:cdos.getColValue("fecha")%>" />
      <jsp:param name="fieldClass" value="Text10" />
      <jsp:param name="buttonClass" value="Text10" />
      </jsp:include>
    </td>
    <td><jsp:include page="../common/calendar.jsp" flush="true">
      <jsp:param name="noOfDateTBox" value="1" />
      <jsp:param name="clearOption" value="true" />
      <jsp:param name="nameOfTBox1" value="<%=hora_entrada%>"/>
      <jsp:param name="format" value="hh12:mi am" />
      <jsp:param name="valueOfTBox1" value="<%=(cdos.getColValue("hora_entrada")==null)?"":cdos.getColValue("hora_entrada")%>" />
      <jsp:param name="fieldClass" value="Text10" />
      <jsp:param name="buttonClass" value="Text10" />
      </jsp:include>
    </td>
	
    <td>
      <jsp:include page="../common/calendar.jsp" flush="true">
      <jsp:param name="noOfDateTBox" value="1" />
      <jsp:param name="clearOption" value="true" />
      <jsp:param name="nameOfTBox1" value="<%=fecha_salida%>"/>						
      <jsp:param name="valueOfTBox1" value="<%=(cdos.getColValue("fecha_salida")==null)?"":cdos.getColValue("fecha_salida")%>" />
      <jsp:param name="fieldClass" value="Text10" />
      <jsp:param name="buttonClass" value="Text10" />
      </jsp:include>
    </td>
	
    <td><jsp:include page="../common/calendar.jsp" flush="true">
      <jsp:param name="noOfDateTBox" value="1" />
      <jsp:param name="clearOption" value="true" />
      <jsp:param name="nameOfTBox1" value="<%=hora_salida%>"/>
      <jsp:param name="format" value="hh12:mi am" />
      <jsp:param name="valueOfTBox1" value="<%=(cdos.getColValue("hora_salida")==null)?"":cdos.getColValue("hora_salida")%>" />
      <jsp:param name="fieldClass" value="Text10" />
      <jsp:param name="buttonClass" value="Text10" />
      </jsp:include>
    </td>

     <td> <%=fb.decBox("tiempo"+i,cdos.getColValue("tiempo"),(cdos.getAction().equalsIgnoreCase("D"))?false:true,false,false,3,"Text10",null,"onChange=\"javascript:cambioValue("+i+")\"")%>
</td>

	   <td><%=fb.select("accion"+i,"ND=NO DESCONTAR,DS=DESCONTAR,DV=DEVOLVER",cdos.getColValue("accion"),false,false,0,"Text10",null,"onChange=\"javascript:chkValue("+i+")\"")%></td>
    
    <td>
		<%=fb.intBox("motivo_falta"+i,cdos.getColValue("motivo_falta"), (cdos.getAction().equalsIgnoreCase("D"))?false:true,false,true,2,3,"Text10",null,null)%>
		<%=fb.textBox("motivo_falta_desc"+i,cdos.getColValue("motivo_falta_desc"),false,false,true,25,"Text10",null,null)%>
		<%=fb.button("btnmotivo"+i,"...",true,false,null,null,"onClick=\"javascript:addMotivo("+i+")\"")%>
    </td>
	
 
    <td><%=fb.decBox("monto"+i,cdos.getColValue("monto"),false,false,false,5, 8.2,null,null,"onFocus=\"this.select();\"","Monto",false,"")%></td>
    <td align="center"><%=fb.submit("rem"+i,"X",false,viewMode,"","","onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Registro")%>
	
	</td>
</tr>
  <tr class="TextRow01"  <%=style%>>
  	<td colspan="11"><table width="100%">
      <tr>
        <td align="center">A&ntilde;o</td>
        <td align="center">Periodo</td>
        <td colspan="3" align="center">Planilla</td>
        <td align="center">Estado</td>
        <td align="center">Fecha</td>
        <td colspan="4" align="center">Comentario</td>
      </tr>
      <tr class="<%=color%>" <%=style%> align="center">
        <td><%=fb.intBox("anio_des"+i,cdos.getColValue("anio_des"),(cdos.getAction().equalsIgnoreCase("D"))?false:true,false,false,5,5,"Text10",null,"onChange=\"javascript:chkPlanilla("+i+")\"")%></td>
        <td><%=fb.intBox("quincena_des"+i,cdos.getColValue("quincena_des"),(cdos.getAction().equalsIgnoreCase("D"))?false:true,false,false,5,5,"Text10",null,"onChange=\"javascript:chkPlanilla("+i+")\"")%></td>
        <td colspan="3">
		<%=fb.select(ConMgr.getConnection(),"select cod_planilla as codpla, nombre, cod_planilla from tbl_pla_planilla where compania="+(String) session.getAttribute("_companyId")+" and is_visible ='S' order by 1","cod_planilla_des"+i,cdos.getColValue("cod_planilla_des"),false,false,0,"Text10",null,"onChange=\"javascript:chkPlanilla("+i+")\"")%>
		 </td>
        <td><%=fb.select("estado_des"+i,"PE=PENDIENTE,DS=DESCONTADO",cdos.getColValue("estado_des"),false,false,0,"Text10",null,null)%></td>
        <td>
		  <jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="1" />
          <jsp:param name="clearOption" value="true" />
          <jsp:param name="nameOfTBox1" value="<%=fecha_des%>"/>
          <jsp:param name="valueOfTBox1" value="<%=(cdos.getColValue("fecha_des")==null)?"":cdos.getColValue("fecha_des")%>" />
          <jsp:param name="fieldClass" value="Text10" />
          <jsp:param name="buttonClass" value="Text10" />
          </jsp:include>
		</td>
    
        <td colspan="4"><%=fb.textarea("comentario"+i,cdos.getColValue("comentario"),false,false,false,35,2)%></td>
      </tr>
	  				
		<%}  } %>
	</table>
 </td>
 </tr>
 
 	
<tr class="TextRow02">
    <td align="right" colspan="11"> Opciones de Guardar: 
	<%=fb.radio("saveOption","N")%>Crear Otro 
	<%=fb.radio("saveOption","O")%>Mantener Abierto 
	<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
	<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
	<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
</tr>
		
	<tr>
		<td colspan="11">&nbsp;</td>
	</tr>
		 <%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</table>		
	</td>
	</tr>
</table>		
</body>
</html>
<%
}//GET 
else if(request.getMethod().equalsIgnoreCase("POST"))
{
String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction = request.getParameter("baction");

ArrayList list= new ArrayList();
//desclastLineNo= Integer.parseInt(request.getParameter("desclastLineNo"));
int keySize=Integer.parseInt(request.getParameter("keySize"));
String itemRemoved="";
htdesc.clear();
for(int a=0; a<keySize; a++)
{ 
 CommonDataObject cdo = new CommonDataObject();
  cdo.setTableName("tbl_pla_aus_y_tard");  
  cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and estado_des = 'PE' and emp_id="+empId+" and secuencia ="+request.getParameter("secuencia"+a));
  //cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and emp_id="+emp_id);
  	cdo.addColValue("emp_id",empId);
  	cdo.addColValue("provincia",request.getParameter("provincia"));
  	cdo.addColValue("sigla",request.getParameter("sigla"));
  	cdo.addColValue("tomo",request.getParameter("tomo"));
  	cdo.addColValue("asiento",request.getParameter("asiento"));
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("fecha", request.getParameter("fecha"+a));
	cdo.addColValue("comentario", request.getParameter("comentario"+a));
	
	if(request.getParameter("fecha_salida"+a)!=null && !request.getParameter("fecha_salida"+a).equals("")) cdo.addColValue("fecha_salida", request.getParameter("fecha_salida"+a));
	if(request.getParameter("tipo_trx"+a)!=null && !request.getParameter("tipo_trx"+a).equals("")) cdo.addColValue("tipo_trx", request.getParameter("tipo_trx"+a));
	if(request.getParameter("secuencia"+a)!=null && !request.getParameter("secuencia"+a).equals("")) cdo.addColValue("secuencia", request.getParameter("secuencia"+a));
	if(request.getParameter("hora_entrada"+a)!=null && !request.getParameter("hora_entrada"+a).equals("")) cdo.addColValue("hora_entrada", request.getParameter("hora_entrada"+a));
	if(request.getParameter("hora_salida"+a)!=null && !request.getParameter("hora_salida"+a).equals("")) cdo.addColValue("hora_salida", request.getParameter("hora_salida"+a));
	if(request.getParameter("motivo_falta"+a)!=null && !request.getParameter("motivo_falta"+a).equals("")) cdo.addColValue("motivo_falta", request.getParameter("motivo_falta"+a));
	if(request.getParameter("motivo_falta_desc"+a)!=null && !request.getParameter("motivo_falta_desc"+a).equals("")) cdo.addColValue("motivo_falta_desc", request.getParameter("motivo_falta_desc"+a));
	if(request.getParameter("accion"+a)!=null && !request.getParameter("accion"+a).equals("")) cdo.addColValue("accion", request.getParameter("accion"+a));
	if(request.getParameter("tiempo"+a)!=null && !request.getParameter("tiempo"+a).equals("")) cdo.addColValue("tiempo", request.getParameter("tiempo"+a));
	if(request.getParameter("monto"+a)!=null && !request.getParameter("monto"+a).equals("")) cdo.addColValue("monto", request.getParameter("monto"+a));
	if(request.getParameter("anio_des"+a)!=null && !request.getParameter("anio_des"+a).equals("")) cdo.addColValue("anio_des", request.getParameter("anio_des"+a));
	if(request.getParameter("quincena_des"+a)!=null && !request.getParameter("quincena_des"+a).equals("")) cdo.addColValue("quincena_des", request.getParameter("quincena_des"+a));
	if(request.getParameter("cod_planilla_des"+a)!=null && !request.getParameter("cod_planilla_des"+a).equals("")) cdo.addColValue("cod_planilla_des", request.getParameter("cod_planilla_des"+a));
	if(request.getParameter("cod_planilla_des_desc"+a)!=null && !request.getParameter("cod_planilla_des_desc"+a).equals("")) cdo.addColValue("cod_planilla_des_desc", request.getParameter("cod_planilla_des_desc"+a));
	if(request.getParameter("estado_des"+a)!=null && !request.getParameter("estado_des"+a).equals("")) cdo.addColValue("estado_des", request.getParameter("estado_des"+a));
	if(request.getParameter("fecha_des"+a)!=null && !request.getParameter("fecha_des"+a).equals("")) cdo.addColValue("fecha_des", request.getParameter("fecha_des"+a));
		cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		if(request.getParameter("usuario_creacion"+a)!=null && !request.getParameter("usuario_creacion"+a).trim().equals(""))cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+a));
		else cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		if(request.getParameter("fecha_creacion"+a)!=null && !request.getParameter("fecha_creacion"+a).trim().equals(""))cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+a));
		else cdo.addColValue("fecha_creacion",cDateTime); 
		cdo.addColValue("fecha_modificacion",cDateTime); 
		cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
	 if(request.getParameter("tiempo"+a)!=null && !request.getParameter("tiempo"+a).equals(""))cdo.addColValue("cantidad", request.getParameter("tiempo"+a));
  
   cdo.addColValue("secuencia",request.getParameter("secuencia"+a));  
   cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId")+" and emp_id="+request.getParameter("empId"));
   cdo.setAutoIncCol("secuencia");  
   
  cdo.setKey(a);
  cdo.setAction(request.getParameter("action"+a));

    if (request.getParameter("remove"+a) != null && !request.getParameter("remove"+a).equals(""))
	{
		itemRemoved = cdo.getKey();
		if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
		else cdo.setAction("D");
	}
	
	if (!cdo.getAction().equalsIgnoreCase("X"))
	{
		try
		{
			htdesc.put(cdo.getKey(),cdo);
			list.add(cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}
 }//End For
 
if(!itemRemoved.equals(""))
{ 
	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&empId="+empId+"&fp="+fp+"&fg="+fg);
	return;
}

if(request.getParameter("btnagregar")!=null)
{
CommonDataObject cdo = new CommonDataObject();
	cdo.addColValue("fecha", "");
		cdo.addColValue("fecha_salida", "");
		cdo.addColValue("tipo_trx", "");
		cdo.addColValue("secuencia", "0");
		cdo.addColValue("hora_entrada", "");
		cdo.addColValue("hora_salida", "");
		cdo.addColValue("motivo_falta", "");
		cdo.addColValue("motivo_falta_desc", "");
		cdo.addColValue("accion", "");
		cdo.addColValue("tiempo", "");
		cdo.addColValue("fecha_creacion",cDateTime);
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("cantidad", "0");
		cdo.addColValue("monto", "");
		cdo.addColValue("anio_des", "");
		cdo.addColValue("quincena_des", "");
		if(fp.equalsIgnoreCase("liquidacion")) { 
		cdo.addColValue("cod_planilla_des", "8");
		cdo.addColValue("cod_planilla_des_desc", "");
		}
		else {
		cdo.addColValue("cod_planilla_des", "");
		cdo.addColValue("cod_planilla_des_desc", "");
		}
		cdo.addColValue("estado_des", "");
		cdo.addColValue("fecha_des", "");
		cdo.addColValue("fecha",cDateTime.substring(0,10));
		cdo.setAction("I");
		cdo.setKey(htdesc.size() + 1);
		htdesc.put(cdo.getKey(),cdo);
		 
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&empId="+empId+"&fp="+fp+"&fg="+fg);
 return;
}

if(list.size()==0)
{
	CommonDataObject cdo = new CommonDataObject();
    cdo.setTableName("tbl_pla_aus_y_tard");  
    cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+"  and estado_des ='PE' and empId="+empId);
	cdo.setKey(htdesc.size() + 1);
	cdo.setAction("I");
	list.add(cdo);
} 

ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fp="+fp+"&fg="+fg);
 SQLMgr.saveList(list,true);
ConMgr.clearAppCtx(null);


%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (fp.equals("liquidacion")||fp.equals("LIQ")||fp.equals("LIQNEW")){
	if (fp.equals("LIQNEW")){
	%>
	window.opener.reloadPage('TRX',1);
	<%}else{%>
	window.opener.getPlaLiqDLTotales();
	<%}
	} else {
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/registro_transaccion_list.jsp"))
		{
%>
	//window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/registro_transaccion_list.jsp")%>';
<%
		}
		else
		{
%>
	//window.opener.location = '<%=request.getContextPath()%>/rhplanilla/registro_transaccion_list.jsp';
<%
		}
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>&empId=<%=empId%>&fg=<%=fg%>';
}

</script>

</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
