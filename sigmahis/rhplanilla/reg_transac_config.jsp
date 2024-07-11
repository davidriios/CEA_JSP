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
/**
================================================================================
800055	AGREGAR TRANSACCIONES
800056	MODIFICAR E EMPLEADOS
================================================================================
**/
SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String key="";
String empId= request.getParameter("empId");
String num_empleado=request.getParameter("num");
String fp = request.getParameter("fp");
if(fp==null) fp = "";
ArrayList al= new ArrayList();
String change= request.getParameter("change");
//String fecha_inicial=
int desclastLineNo =0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if(request.getParameter("desclastLineNo")!=null && ! request.getParameter("desclastLineNo").equals(""))
desclastLineNo=Integer.parseInt(request.getParameter("desclastLineNo"));
else desclastLineNo=0;
boolean viewMode = false;
String mode=request.getParameter("mode");
if(mode == null) mode = "add";
if(mode.equals("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(change==null)
{
		htdesc.clear();

sql = "select a.provincia, a.sigla, a.tomo, a.asiento, a.codigo as codigo, a.tipo_trx as tipo_trx, to_char(a.monto,'99999990.00') as monto, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.cantidad, to_char(a.fecha_inicio,'dd/mm/yyyy') fecha_inicio, to_char(a.fecha_final,'dd/mm/yyyy') fecha_final, a.anio_pago, a.compania, a.mes_pago, a.quincena_pago, a.cod_planilla_pago, a.estado_pago, decode(a.estado_pago,'PE','Pendiente','PA','Pagado','AN','Anulado') desc_estado, to_char(a.fecha_pago,'dd/mm/yyyy') fecha_pago, a.comentario, a.accion, a.vobo_estado, a.grupo, a.monto_unitario, a.num_empleado, b.primer_nombre, b.primer_apellido, b.unidad_organi, c.descripcion as unidadName, d.descripcion as tipotrxDesc,  b.salario_base, b.rata_hora ,  b.emp_id,to_char(a.fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fecha_creacion,a.usuario_creacion from tbl_pla_transac_emp a, tbl_pla_empleado b,  tbl_sec_unidad_ejec c, tbl_pla_tipo_transaccion d where  a.emp_id=b.emp_id and a.compania=b.compania(+) and  b.unidad_organi=c.codigo(+) and a.compania = c.compania and a.compania = d.compania and a.tipo_trx= d.codigo and a.estado_pago ='PE' and a.aprobacion_estado = 'S'  and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId+"and not exists  (select null from tbl_pla_planilla_encabezado where cod_compania = a.compania and anio = a.anio_pago and cod_planilla = a.cod_planilla_pago and num_planilla = a.quincena_pago and estado in ('B','D')) ";

	al=SQLMgr.getDataList(sql);
desclastLineNo=al.size();
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
document.title="Registro de Tran. Empleados - Agregar - "+document.title;

function doAction(){setEmpleadoInfo('form1');
	var size = <%=htdesc.size()%>;
	if(size>0){
		var x = getDBData('<%=request.getContextPath()%>', 'getAnioPlanilla(<%=(String) session.getAttribute("_companyId")%>)','dual','','');
		var arr_cursor = new Array();
		if(x!=''){
			arr_cursor = splitCols(x);
			for(i=0;i<size;i++){
			if(eval('document.form1.action'+i).value == 'I'){
				if(eval('document.form1.anio_pago'+i).value == '') eval('document.form1.anio_pago'+i).value = arr_cursor[0];
				if(eval('document.form1.quincena_pago'+i).value == '') eval('document.form1.quincena_pago'+i).value = arr_cursor[1];}
			}
		}
	}
}
function tipo(codeField, descField)
{
abrir_ventana1('../rhplanilla/list_tipo_transaccion.jsp?fp=registro&codeField='+codeField+'&descField='+descField);
}
function chkValue(i){
	var cantidad = eval('document.form1.cantidad'+i).value;
	var monto_unitario = eval('document.form1.monto_unitario'+i).value;
	if(monto_unitario=='')monto_unitario = document.form1.rataHora.value;
	eval('document.form1.monto_unitario'+i).value = monto_unitario;
	var x = 0;
	if(cantidad!='')cantidad = parseFloat(cantidad);
	if(monto_unitario!='')monto_unitario = parseFloat(monto_unitario);
	if(isNaN(cantidad)||cantidad==''){
		alert('Introduzca valores Numéricos!');
		eval('document.form1.cantidad'+i).value = '';
		x++;
	} else if(isNaN(monto_unitario)||monto_unitario==''){
		alert('Introduzca valores Numéricos!');
		eval('document.form1.monto_unitario'+i).value = '';
		x++;
	}

	if(x==0){
		eval('document.form1.monto'+i).value = Math.round(parseFloat(cantidad) * parseFloat(monto_unitario)*100)/100;
		return true;
	}
	else return false;
}
function chkPlanilla(i)
{
				var anio= eval('document.form1.anio_pago'+i).value;
				var periodo =eval('document.form1.quincena_pago'+i).value;
				var cod_planilla =eval('document.form1.cod_planilla_pago'+i).value;
				if(anio=='0') alert('Año Invalido!');
				if(periodo =='0')alert('Periodo Invalido!');
				
				if(anio!='0' && periodo !='0')
				{
					if(anio!='' && periodo !='')
					{
						if(hasDBData('<%=request.getContextPath()%>','tbl_pla_planilla_encabezado','cod_compania=<%=(String) session.getAttribute("_companyId")%> and cod_planilla='+cod_planilla+' and num_planilla ='+periodo+' and anio='+anio+' ',''))
						{
							alert('La planilla ya se encuentra Procesada!');
							eval('document.form1.quincena_pago'+i).value ='';
						}
					}
				}

}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REGISTRO DE TRANSACIONES DE EMPLEADOS"></jsp:param>
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
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("empId",empId)%>
	<%=fb.hidden("desclastLineNo",""+desclastLineNo)%>
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
	<tr class="TextHeader">
		<td colspan="4">&nbsp;<cellbytelabel>Registro de Transacciones</cellbytelabel></td>
	</tr>
	<tr>
    <td colspan="4">
		<table width="100%">
    <tr class="TextHeader" align="center">
		<td width="7%" rowspan="2"><cellbytelabel>N&uacute;m</cellbytelabel>.</td>
    <td width="13%" rowspan="2" align="center"><cellbytelabel>Fecha</cellbytelabel> </td>
		<td rowspan="1" align="center"><cellbytelabel>Tipo</cellbytelabel> </td>
		<td rowspan="1"  align="center"><cellbytelabel>Fecha Transaccion</cellbytelabel></td>
		<td width="8%" rowspan="2"><cellbytelabel>Cantidad</cellbytelabel></td>
		<td width="10%" rowspan="2"><cellbytelabel>Monto Unitario</cellbytelabel></td>
    <td width="8%" rowspan="2"><cellbytelabel>Monto</cellbytelabel></td>
		<td width="4%" rowspan="2"><%=fb.submit("btnagregar","+",false,false)%></td>
	</tr>



	<tr class="TextHeader" align="center">
		<td width="24%"><cellbytelabel>Transacci&oacute;n</cellbytelabel></td>
		<td width="25%"><cellbytelabel>Inicial</cellbytelabel>.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>Final</cellbytelabel>.</td>
	</tr>
	<%
	String codigo="0";
	if(htdesc.size()>0)
	al=CmnMgr.reverseRecords(htdesc);
		//for(int i=0; i<htdesc.size();i++)
	for(int i=0; i<al.size();i++)
	{
	key=al.get(i).toString();
		CommonDataObject cdos=(CommonDataObject) htdesc.get(key);

		String color="";
	 	String style = (cdos.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";

		if(i%2 == 0) color ="TextRow02";

		else color="TextRow01";
	%>
	  <%=fb.hidden("remove"+i,"")%>
	  <%=fb.hidden("action"+i,cdos.getAction())%>
	  <%=fb.hidden("key"+i,cdos.getKey())%>
	  <%=fb.hidden("fecha_creacion"+i, cdos.getColValue("fecha_creacion"))%>
	  <%=fb.hidden("usuario_creacion"+i, cdos.getColValue("usuario_creacion"))%>
	  <%if(cdos.getAction().equalsIgnoreCase("D")){%>
			  <%=fb.hidden("codigo"+i, cdos.getColValue("codigo"))%>
			  <%=fb.hidden("tipo_trx"+i,cdos.getColValue("tipo_trx"))%>
			  <%}if(!cdos.getAction().equalsIgnoreCase("D")){%>
	<tr class="<%=color%>" <%=style%>>
		<td align="center"><%=fb.intBox("codigo"+i,cdos.getColValue("codigo"),(cdos.getAction().equalsIgnoreCase("D"))?false:true,false,false,5,3,"Text10",null,null)%></td>
    	<td align="center">
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="1" />
		<jsp:param name="nameOfTBox1" value="<%="fecha"+i%>" />
		<jsp:param name="valueOfTBox1" value="<%=cdos.getColValue("fecha")%>" />
		</jsp:include>	</td>

		<td><%=fb.intBox("tipo_trx"+i,cdos.getColValue("tipo_trx"),(cdos.getAction().equalsIgnoreCase("D"))?false:true,false,true,1,2,"Text10",null,null)%>
			<%=fb.textBox("tipotrxDesc"+i,cdos.getColValue("tipotrxDesc"),false,false,true,25,200,"Text10",null,null)%><%=fb.button("btngrupo"+i,"Ir",true,false,"Text10", null,"onClick=\"javascript:tipo('tipo_trx"+i+"','tipotrxDesc"+i+"');\"" )%>	</td>

     	<td align="center">	<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="nameOfTBox1" value="<%="fecha_inicio"+i%>" />
							<jsp:param name="valueOfTBox1" value="<%=cdos.getColValue("fecha_inicio")%>" />
							</jsp:include>	<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="nameOfTBox1" value="<%="fecha_final"+i%>" />
							<jsp:param name="valueOfTBox1" value="<%=cdos.getColValue("fecha_final")%>" />
							</jsp:include></td>

    	<td><%=fb.decBox("cantidad"+i,cdos.getColValue("cantidad"),(cdos.getAction().equalsIgnoreCase("D"))?false:true,false,false,10,5.2,"Text10",null,"onChange=\"javascript:chkValue("+i+")\"")%></td>
	    <td><%=fb.decBox("monto_unitario"+i,cdos.getColValue("monto_unitario"),(cdos.getAction().equalsIgnoreCase("D"))?false:true,false,false,10,8.2,"Text10",null,"onChange=\"javascript:chkValue("+i+")\"")%></td>
		<td><%=fb.decBox("monto"+i,cdos.getColValue("monto"),(cdos.getAction().equalsIgnoreCase("D"))?false:true,false,false,10,8.2,"Text10",null,null)%></td>
		<td align="center" rowspan="2"><%=fb.submit("rem"+i,"X",false,viewMode,"","","onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Registro")%></td>
	</tr>
			<tr class="TextRow01" <%=style%>>
				    	<td colspan="4">
					    	<table>
							   		<tr>
							      	 	<td><cellbytelabel>Comentario</cellbytelabel></td>
								   			<td><%=fb.textarea("comentario"+i,cdos.getColValue("comentario"),false,false,false,50,3,"Text11",null,null)%></td>
							   		</tr>
								</table>
							</td>

          		<td colspan="3">
					    	<table>
							  	<tr>
							    	  <td width="37%"><cellbytelabel>Acción</cellbytelabel></td>
								   		<td width="63%"><%=fb.select("accion"+i,"PA=Pagar,DE=Descontar",cdos.getColValue("accion"),false,false,0,"Text10",null,null)%></td>
							   		</tr>
                    			<tr>
							      	<td><cellbytelabel>A&ntilde;o</cellbytelabel></td>
								    <td><%=fb.textBox("anio_pago"+i,cdos.getColValue("anio_pago"),true,false,false,5,5,"Text10",null,"onChange=\"javascript:chkPlanilla("+i+")\"")%>
                     <cellbytelabel>Periodo</cellbytelabel><%=fb.textBox("quincena_pago"+i,cdos.getColValue("quincena_pago"),true,false,false,5,5,"Text10",null,"onChange=\"javascript:chkPlanilla("+i+")\"")%></td>
							   	</tr>
                 				<tr>
							     	<td><cellbytelabel>Planilla</cellbytelabel></td>
                      				<td><%=fb.select(ConMgr.getConnection(),"select cod_planilla as codpla, nombre, cod_planilla from tbl_pla_planilla where compania="+(String) session.getAttribute("_companyId")+" and is_visible ='S' order by 1","cod_planilla_pago"+i,cdos.getColValue("cod_planilla_pago"),false,false,0,"Text10",null,"onChange=\"javascript:chkPlanilla("+i+")\"")%>
						<%//=fb.select("cod_planilla_pago"+i,"1=Planilla Quincenal,2=Planilla Décimo,3=Planilla de Vacaciones,5=Planilla de Bonificaciones,6=Planilla de Incentivos,7=Planilla de Ajuste,8=Planilla Liquidaciones,9=Participación en Utilidades",cdos.getColValue("cod_planilla_pago"),false,false,0,"Text10",null,null)%></td>
								</tr>
							</table>
				</td>
			</tr>

	<% } } %>
	</table>
 </td>
 </tr>


	<tr class="TextRow02">
        <td align="right" colspan="4"> <cellbytelabel>Opciones de Guardar</cellbytelabel>:
		<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel>
		<%=fb.radio("saveOption","O")%><cellbytelabel>Mantener Abierto</cellbytelabel>
		<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
		<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
    </tr>
			<%--<tr class="TextRow02">
				<td colspan="4" align="right"> <%//=fb.submit("save","Guardar",true,false)%>
				<%//=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>	--%>
	<tr>
		<td colspan="4">&nbsp;</td>
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
  cdo.setTableName("tbl_pla_transac_emp");
  cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and emp_id="+empId+" and tipo_trx="+request.getParameter("tipo_trx"+a)+" and CODIGO="+request.getParameter("codigo"+a));
  cdo.addColValue("emp_id",empId);
  cdo.addColValue("provincia",request.getParameter("provincia"));
  cdo.addColValue("sigla",request.getParameter("sigla"));
  cdo.addColValue("tomo",request.getParameter("tomo"));
  cdo.addColValue("asiento",request.getParameter("asiento"));
  cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
  cdo.addColValue("tipo_trx",request.getParameter("tipo_trx"+a));
	cdo.addColValue("fecha", request.getParameter("fecha"+a));
	cdo.addColValue("monto",request.getParameter("monto"+a));
	if(request.getParameter("usuario_creacion"+a)!=null && !request.getParameter("usuario_creacion"+a).trim().equals(""))cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+a));
	else cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
	if(request.getParameter("fecha_creacion"+a)!=null && !request.getParameter("fecha_creacion"+a).trim().equals(""))cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+a));
	else cdo.addColValue("fecha_creacion",cDateTime);
	cdo.addColValue("fecha_modificacion",cDateTime);
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("cantidad",request.getParameter("cantidad"+a));
	cdo.addColValue("fecha_inicio", request.getParameter("fecha_inicio"+a));
	cdo.addColValue("fecha_final", request.getParameter("fecha_final"+a));
	cdo.addColValue("anio_pago", request.getParameter("anio_pago"+a));
	cdo.addColValue("tipotrxDesc", request.getParameter("tipotrxDesc"+a));
	//cdo.addColValue("mes_pago", request.getParameter("mes_pago"+a));
	cdo.addColValue("quincena_pago", request.getParameter("quincena_pago"+a));
	cdo.addColValue("cod_planilla_pago", request.getParameter("cod_planilla_pago"+a));
	cdo.addColValue("estado_pago","PE");
	//cdo.addColValue("fecha_pago",request.getParameter("fecha_pago"+a));
	cdo.addColValue("comentario",request.getParameter("comentario"+a));
	cdo.addColValue("accion",request.getParameter("accion"+a));
	cdo.addColValue("vobo_estado","N");
	cdo.addColValue("aprobacion_estado","S");
	cdo.addColValue("monto_unitario",request.getParameter("monto_unitario"+a));
	cdo.addColValue("aprobacion_usuario",(String) session.getAttribute("_userName"));
    cdo.addColValue("aprobacion_fecha",cDateTime);
	cdo.addColValue("anio_reporta",request.getParameter("anio_pago"+a));
	cdo.addColValue("quincena_reporta",request.getParameter("quincena_pago"+a));
	cdo.addColValue("cod_planilla_reporta",request.getParameter("cod_planilla_pago"+a));
    cdo.addColValue("grupo",request.getParameter("grupo"));
    cdo.addColValue("num_empleado",request.getParameter("num_empleado"));
 // cdo.addColValue("vobo_fecha",request.getParameter("vobo_fecha"+a));
//	cdo.addColValue("vobo_usuario",request.getParameter("vobo_usuario"+a));
//	cdo.addColValue("sub_tipo_trx",request.getParameter("sub_tipo_trx"+a));
 // cdo.addColValue("monto_unitario",request.getParameter("monto_unitario"+a));
//	cdo.addColValue("rprovincia",CmnMgr.getCurrentDate("rprovincia"+a));
//  cdo.addColValue("rsigla",CmnMgr.getCurrentDate("rsigla"+a));
//	cdo.addColValue("rtomo",CmnMgr.getCurrentDate("rtomo"+a));
//	cdo.addColValue("rasiento",CmnMgr.getCurrentDate("rasiento"+a));
//	cdo.addColValue("rnum_empleado",request.getParameter("rnum_empleado"+a));
 // cdo.addColValue("aprobacion_estado",request.getParameter("aprobacion_estado"+a));

   cdo.addColValue("codigo",request.getParameter("codigo"+a));
  cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId")+" and emp_id="+request.getParameter("empId"));
  cdo.setAutoIncCol("codigo");

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
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&empId="+empId+"&desclastLineNo="+desclastLineNo+"&fp="+fp);
return;
}

if(request.getParameter("btnagregar")!=null)
{
CommonDataObject cdo = new CommonDataObject();
cdo.addColValue("tipo_trx","");
cdo.addColValue("codigo","0");
cdo.addColValue("fecha_inicio","");
cdo.addColValue("fecha_final","");
cdo.addColValue("fecha_creacion",cDateTime);
cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
cdo.addColValue("fecha",cDateTime.substring(0,10));
cdo.setAction("I");
cdo.setKey(htdesc.size() + 1);
htdesc.put(cdo.getKey(),cdo);
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&empId="+empId+"&desclastLineNo="+desclastLineNo+"&fp="+fp);
 return;
}
if(list.size()==0)
{
	CommonDataObject cdo = new CommonDataObject();
  	cdo.setTableName("tbl_pla_transac_emp");
  	cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and emp_id="+empId+"  ");
	cdo.setKey(htdesc.size() + 1);
	cdo.setAction("I");
	list.add(cdo);
}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fp="+fp);
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
	window.opener.reloadPage('TRX');
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?empId=<%=empId%>&fp=<%=fp%>';
}

</script>

</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
