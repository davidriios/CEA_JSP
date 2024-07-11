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
<jsp:useBean id="htdesc" scope="session" class="java.util.Hashtable"/><%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CommonDataObject desc= new CommonDataObject();
String sql="";
String key="";
String emp_id= request.getParameter("emp_id");
String prov=request.getParameter("prov");
String sig=request.getParameter("sig");
String tom=request.getParameter("tom");
String asi=request.getParameter("asi");
String num_empleado=request.getParameter("num");
String grupo=request.getParameter("grp");
String rata=request.getParameter("rath");
String fp=request.getParameter("fp");
String anio_pago=request.getParameter("anio_pago");
String quincena_pago=request.getParameter("quincena_pago");
String fecha = request.getParameter("fecha");
if(fp==null) fp="";
if(anio_pago==null) anio_pago="";
if(quincena_pago==null) quincena_pago="";
ArrayList al= new ArrayList();
String change= request.getParameter("change");
//String fecha_inicial=
int desclastLineNo =0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
boolean viewMode = false;
String mode=request.getParameter("mode");
if(mode == null) mode = "add";
if(mode.equals("view")) viewMode = true;

if(request.getParameter("desclastLineNo")!=null && ! request.getParameter("desclastLineNo").equals(""))
desclastLineNo=Integer.parseInt(request.getParameter("desclastLineNo"));
else desclastLineNo=0;

if(anio_pago.trim().equals("")) anio_pago = cDateTime.substring(6, 10);

if(quincena_pago.trim().equals("")) {
int day = Integer.parseInt(CmnMgr.getCurrentDate("dd"));
int mont = Integer.parseInt(CmnMgr.getCurrentDate("mm"));
int period=0;
if(fecha==null) fecha = cDateTime;

if (day<=15) {
			period		= (mont * 2)-1;

}	else {
		  period		= (mont * 2);
}
quincena_pago = ""+period;
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
desc.addColValue("fecha",cDateTime.substring(0,10));

sql="select e.num_empleado,e.provincia as primero, e.sigla as segundo, e.tomo as tercero, e.asiento as cuarto, e.primer_nombre as nameprimer, e.primer_apellido as Apellido, e.unidad_organi, to_char(e.salario_base,'999,999,990.00') as salario, to_char(e.rata_hora,'990.000000') as rata, u.descripcion as unidad  from tbl_pla_empleado e, tbl_sec_unidad_ejec u where e.unidad_organi=u.codigo(+) and e.compania=u.compania(+) and e.compania="+(String) session.getAttribute("_companyId")+" and e.emp_id="+emp_id;
desc = SQLMgr.getData(sql);

if(change==null)
{
		htdesc.clear();

sql = "select a.provincia, a.sigla, a.tomo, a.asiento, a.codigo as codigo, to_char(a.saldo,'99,999,990.00') as saldo, to_char(a.fecha_inicio,'dd/mm/yyyy') as fecha_inicio,  to_char(a.fecha_final,'dd/mm/yyyy') fechaFinal, a.anio_pag, a.mes_pag, a.cantidad, a.aprobado, a.comentario, a.forma_pago as forma_pago, a.the_codigo as  the_codigo, a.mes_pag, to_char(a.hora_inicio,'hh:mi') as horaInicio,  to_char(a.hora_final,'hh:mi') horFinal, decode(a.estado_pag,'PE','Pendiente','PA','Pagado','AN','Anulado') as desc_estado, a.estado_pag, a.quincena_pag, to_char(a.fecha_pag,'dd/mm/yyyy') as fechaPago, a.cantidad_aprob, a.cod_planilla_pag, to_char(a.monto,'99,999,990.00') as monto, a.vobo_estado, a.vobo_usuario, to_char(a.vobo_fecha,'dd/mm/yyyy') as voboFecha, b.primer_nombre, b.primer_apellido, b.unidad_organi, c.descripcion as unidadName, d.descripcion as tipoextDesc, to_char(d.factor_multi,'999.000000') as factor, b.salario_base, to_char(b.rata_hora,'999.000000') as rataHora,  b.emp_id from tbl_pla_t_extraordinario a, tbl_pla_empleado b,  tbl_sec_unidad_ejec c, tbl_pla_t_horas_ext d where a.provincia=b.provincia and a.sigla=b.sigla and a.tomo=b.tomo and a.asiento=b.asiento and a.compania=b.compania(+) and  b.unidad_organi=c.codigo(+) and a.compania = c.compania and  a.the_codigo = d.codigo and a.estado_pag ='PE'  and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+emp_id;


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
document.title="Registro de Sobretiempos de Empleados - Agregar - "+document.title;
function doAction(){
	var size = <%=htdesc.size()%>;
	if(size>0){
		for(i=0;i<size;i++){
			if(eval('document.form1.anio_pag'+i).value == '') eval('document.form1.anio_pag'+i).value = '<%=anio_pago%>';
			if(eval('document.form1.quincena_pag'+i).value == '') eval('document.form1.quincena_pag'+i).value = '<%=quincena_pago%>';
		}
	}
}

function tipo(index)
{
var  count = 0;
var  rata  = '';
var  cant  = '';
var  factor  = '';
var  multip  = '';
  if(eval("document.form1.cantidad_aprob"+index).value <= 0)
     {
     alert('seleccione una Cantidad para calcular las Extras');
     return;
	 }
	  if(eval("document.form1.rata"+index).value <= 0)
     {
     alert('empleado sin Rata por Hora para calcular las Extras');
     return;
	 }

cant 	 = eval("document.form1.cantidad_aprob"+index).value;
rata 	 = eval("document.form1.rata"+index).value;
 abrir_ventana1("../common/search_tipohoraExtra.jsp?fp=extra&index="+index+"&cant="+cant+"&rata="+rata);
}

function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}

function chkValue(flag, i){
	var cantidad 					= eval('document.form1.cantidad'+i).value;
	var cantidad_aprob 		= eval('document.form1.cantidad_aprob'+i).value;
	var forma_pago 				= eval('document.form1.forma_pago'+i).value;
	var the_codigo 				= eval('document.form1.the_codigo'+i).value;
	var rata 							= eval('document.form1.rata'+i).value;
	var anio_pag 					= eval('document.form1.anio_pag'+i).value;
	var quincena_pag 			= eval('document.form1.quincena_pag'+i).value;
	var cod_planilla_pag	= eval('document.form1.cod_planilla_pag'+i).value;
	var emp_id						= document.form1.emp_id.value;
	var x = 0;
	var v_factor = 0.00;
	cantidad = parseFloat(cantidad);
	cantidad_aprob = parseFloat(cantidad_aprob);
	if(isNaN(cantidad) && flag == 'c'){
		alert('Introduzca valores Numéricos!');
		eval('document.form1.cantidad'+i).value = '';
		x++;
	} else if(isNaN(cantidad_aprob) && flag == 'ca'){
		alert('Introduzca valores Numéricos!');
		eval('document.form1.cantidad_aprob'+i).value = '';
		x++;
	}

	eval('document.form1.aprobado'+i).checked=true;
	if(x==0){
		if(flag=='c'){
			eval('document.form1.cantidad_aprob'+i).value = cantidad;
			eval('document.form1.saldo'+i).value = cantidad;
			 if (the_codigo != '')  {
			 var x = getDBData('<%=request.getContextPath()%>', 'factor_multi','tbl_pla_t_horas_ext','codigo = '+the_codigo,'');
				if(x==''){
					alert('Tipo de Hora Extra no definido. Verifique...'+x);
					v_factor = 0;
				} else  {v_factor = parseFloat(x);
				var tmp=Math.round(cantidad * v_factor * rata * 100);}

				if(forma_pago = 'DI') eval('document.form1.monto'+i).value = (tmp/100).toFixed(2);
				else eval('document.form1.monto'+i).value = 0;
			return true;
		}
		} else if(flag == 'c' || flag=='ca' || flag == 'tc' || flag == 'fp'){
			if(flag=='ca' || flag=='c')eval('document.form1.saldo'+i).value = cantidad_aprob;
			if(cantidad_aprob != '' && the_codigo != '' && forma_pago == 'DI'){
				var x = getDBData('<%=request.getContextPath()%>', 'factor_multi','tbl_pla_t_horas_ext','codigo = '+the_codigo,'');
				if(x==''){
					alert('Tipo de Hora Extra no definido. Verifique...');
					v_factor = 0;
				} else v_factor = parseFloat(x);
				var tmp=Math.round(cantidad_aprob * v_factor * rata * 100);
				if(forma_pago = 'DI') eval('document.form1.monto'+i).value = (tmp/100).toFixed(2);
				else eval('document.form1.monto'+i).value = 0;
			} else {
				eval('document.form1.monto'+i).value = 0;
			}
			if(flag=='tc' && anio_pag == '' && quincena_pag == '' && cod_planilla_pag == ''){
				var x = getDBData('<%=request.getContextPath()%>', 'getAnioPlanilla(<%=(String) session.getAttribute("_companyId")%>)','dual','','');
				var arr_cursor = new Array();
				if(x!=''){
					arr_cursor = splitCols(x);
					for(i=0;i<size;i++){
						if(eval('document.form1.anio_pag'+i).value == '') eval('document.form1.anio_pag'+i).value = arr_cursor[0];
						if(eval('document.form1.quincena_pag'+i).value == '') eval('document.form1.quincena_pag'+i).value = arr_cursor[1];
						if(eval('document.form1.cod_planilla_pag'+i).value == '') eval('document.form1.cod_planilla_pag'+i).value = arr_cursor[2];
						//if(eval('document.form1.planilla_desc'+i).value == '') eval('document.form1.planilla_desc'+i).value = arr_cursor[3];
					}
				}
			} else if(flag=='fp' && forma_pago == 'DI'){
				var x = getDBData('<%=request.getContextPath()%>', 'getFormaPagoMsg(<%=(String) session.getAttribute("_companyId")%>,'+emp_id+',\''+fecha_inicio+'\')','dual','','');
				if(x!='') alert(x);
			}
		}
		return true;
	}
	else return false;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="REGISTRO DE SOBRETIEMPO DE EMPLEADOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
        <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
        <%=fb.formStart(true)%>
				<%=fb.hidden("emp_id",emp_id)%>
				<%=fb.hidden("desclastLineNo",""+desclastLineNo)%>
				<%=fb.hidden("keySize",""+htdesc.size())%>
				<%=fb.hidden("prov",desc.getColValue("primero"))%>
				<%=fb.hidden("sig",desc.getColValue("segundo"))%>
				<%=fb.hidden("tom",desc.getColValue("tercero"))%>
				<%=fb.hidden("asi",desc.getColValue("cuarto"))%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("num_empleado",num_empleado)%>
				<%=fb.hidden("grupo",grupo)%>
				<%=fb.hidden("rata",rata)%>
        <%=fb.hidden("anio_pago",anio_pago)%>
        <%=fb.hidden("quincena_pago",quincena_pago)%>
        <%=fb.hidden("fp",fp)%>
        <% String rataHour= desc.getColValue("rata"); %>
        <tr>
          <td colspan="4">&nbsp;</td>
        </tr>
        <tr class="TextRow02">
          <td colspan="4">&nbsp;</td>
        </tr>
        <tr class="TextHeader">
          <td colspan="4">&nbsp;<cellbytelabel>Generales de Empleado</cellbytelabel></td>
        </tr>
        <tr class="TextRow01" >
          <td height="22">&nbsp;<cellbytelabel>N&uacute;mero de C&eacute;dula</cellbytelabel></td>
          <td colspan="1">&nbsp;<%=desc.getColValue("primero")%>&nbsp;-&nbsp;<%=desc.getColValue("segundo")%>&nbsp;-&nbsp;<%=desc.getColValue("tercero")%>&nbsp;-&nbsp;<%=desc.getColValue("cuarto")%></td>
          <td width="20%">&nbsp;<cellbytelabel>Rata por Hora</cellbytelabel></td>
          <td width="30%">&nbsp;<%=desc.getColValue("rata")%></td>
        </tr>
        <tr class="TextRow01">
          <td width="16%">&nbsp;<cellbytelabel>Nombre</cellbytelabel></td>
          <td width="34%">&nbsp;<%=desc.getColValue("namePrimer")%></td>
          <td width="20%">&nbsp;<cellbytelabel>Apellido</cellbytelabel></td>
          <td width="30%">&nbsp;<%=desc.getColValue("Apellido")%></td>
        </tr>
        <tr class="TextRow01">
          <td>&nbsp;<cellbytelabel>Unidad Administrativa</cellbytelabel></td>
          <td>&nbsp;<%=desc.getColValue("unidad")%></td>
          <td>&nbsp;<cellbytelabel>Salario Base</cellbytelabel></td>
          <td>&nbsp;<%=desc.getColValue("salario")%></td>
        </tr>
        <tr class="TextRow01">
          <td>&nbsp;Grupo</td>
          <td>&nbsp;<%=desc.getColValue("unidad_organi")%></td>
          <td>&nbsp;<cellbytelabel>Numero Empleado</cellbytelabel></td>
          <td>&nbsp;<%=desc.getColValue("num_empleado")%></td>
        </tr>
        <tr class="TextHeader">
          <td colspan="4">&nbsp;<cellbytelabel>Registro de Sobretiempo</cellbytelabel></td>
        </tr>
        <tr>
          <td colspan="4"><table width="100%">
              <tr class="TextHeader" align="center">
                <td width="7%" >N&uacute;m.</td>
                <td width="13%" align="center"><cellbytelabel>Fecha</cellbytelabel> </td>
                <td width="15%" align="center"><cellbytelabel>T. Generado</cellbytelabel> </td>
                <td width="15%" align="center"><cellbytelabel>T. Aprobado</cellbytelabel></td>
                <td width="30%"><cellbytelabel>Tipo de H.Extra</cellbytelabel></td>
                <td width="10%"><cellbytelabel>Aprobado</cellbytelabel></td>
                <td width="5%"><%=fb.submit("btnagregar","+",false,false)%></td>
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
              <%=fb.hidden("saldo"+i,cdos.getColValue("saldo"))%>
			  <%=fb.hidden("remove"+i,"")%>
			  <%=fb.hidden("action"+i,cdos.getAction())%>
			  <%=fb.hidden("key"+i,cdos.getKey())%>
			  <%=fb.hidden("fecha_creacion"+i, cdos.getColValue("fecha_creacion"))%>
			  <%=fb.hidden("usuario_creacion"+i, cdos.getColValue("usuario_creacion"))%>
			  <%if(cdos.getAction().equalsIgnoreCase("D")){%>
			  <%=fb.hidden("fecha_inicio"+i,cdos.getColValue("fecha_inicio"))%>
			  <%=fb.hidden("codigo"+i, cdos.getColValue("codigo"))%>
			  <%}if(!cdos.getAction().equalsIgnoreCase("D")){%>
              <tr class="<%=color%>" <%=style%> >
                <td align="center"><%=fb.intBox("codigo"+i,cdos.getColValue("codigo"),true,false,false,5,3,"Text10",null,null)%></td>
                <td align="center">
                <jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="nameOfTBox1" value="<%="fecha_inicio"+i%>" />
							<jsp:param name="valueOfTBox1" value="<%=(cdos.getColValue("fecha_inicio")==null)?"":cdos.getColValue("fecha_inicio")%>" />
							</jsp:include>
                </td>
                <td align="center">
								<%=fb.decBox("cantidad"+i,cdos.getColValue("cantidad"),(cdos.getAction().equalsIgnoreCase("D"))?false:true,false,false,8,5.2,"Text10",null,"onChange=\"javascript:chkValue('c', "+i+")\"")%>
                </td>
                <td align="center"><%=fb.decBox("cantidad_aprob"+i,cdos.getColValue("cantidad_aprob"),(cdos.getAction().equalsIgnoreCase("D"))?false:true,false,false,8,8.2,"Text10",null,"onChange=\"javascript:chkValue('ca', "+i+")\"")%></td>
                <td>
				<%=fb.intBox("the_codigo"+i,cdos.getColValue("the_codigo"),(cdos.getAction().equalsIgnoreCase("D"))?false:true,false,true,1,2,"Text10",null,"onChange=\"javascript:chkValue('tc', "+i+")\"")%>
				<%=fb.textBox("tipoextDesc"+i,cdos.getColValue("tipoextDesc"),false,false,true,35,200,"Text10",null,null)%>
				<%=fb.button("btngrupo"+i,"Ir",true,false,"Text10", null,"onClick=\"javascript:tipo("+i+")\"" )%>
                </td>
                <td align="center">
								<%=fb.checkbox("aprobado"+i,"S",(cdos.getColValue("aprobado")!=null && cdos.getColValue("aprobado").equalsIgnoreCase("S")),false)%>
                </td>
                <td align="center" rowspan="3">&nbsp;<%=fb.submit("rem"+i,"X",false,viewMode,"","","onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Registro")%></td>
              </tr>
              <tr class="TextRow01" <%=style%>>
                <td colspan="4"><table >
                    <tr>
                      <td>
                      Forma de Pago <%=fb.select("forma_pago"+i,"DI=Dinero,TC=Tiempo Compensatorio",cdos.getColValue("forma_pago"),false,false,0,"Text10",null,null)%>
                      </td>
                      <td> Factor Multiplicador <%=fb.textBox("factor"+i,cdos.getColValue("factor"),false,false,true,10,10,"Text10",null,null)%></td>
                    </tr>
                  </table></td>
                <td colspan="3"><table >
                    <tr>
                      <td> Rata por Hora <%=fb.textBox("rata"+i,rataHour,false,false,true,10,10,"Text10",null,null)%></td>
                      <td>Monto</td>
                      <td><%=fb.decBox("monto"+i,cdos.getColValue("monto"),false,false,false,10,5.2,"Text10",null,null)%></td>
                    </tr>
                  </table></td>
              </tr>
              <tr class="TextRow01" <%=style%>>
                <td colspan="4"><table>
                    <tr>
                      <td>Comentario</td>
                      <td><%=fb.textarea("comentario"+i,cdos.getColValue("comentario"),false,false,false,50,3,"Text11",null,null)%></td>
                    </tr>
                  </table></td>
                <td colspan="3"><table>
                    <tr>
                      <td width="37%">Acci&oacute;n</td>
                      <td width="63%"><%=fb.select("estado_pag"+i,"PE=PENDIENTE,PA=PAGADO,AN=ANULADO",cdos.getColValue("estado_pag"),false,false,0,"Text10",null,null)%></td>
                    </tr>
                    <tr>
                      <td>Año</td>
                      <td><%=fb.textBox("anio_pag"+i,cdos.getColValue("anio_pag"),false,false,false,5,5,"Text10",null,null)%> Periodo<%=fb.textBox("quincena_pag"+i,cdos.getColValue("quincena_pag"),false,false,false,5,5,"Text10",null,null)%></td>
                    </tr>
                    <tr>
                      <td>Planilla</td>
                      <td><%=fb.select(ConMgr.getConnection(),"select cod_planilla as codpla, nombre, cod_planilla from tbl_pla_planilla where compania="+(String) session.getAttribute("_companyId")+" and is_visible ='S' order by 1","cod_planilla_pag"+i,cdos.getColValue("cod_planilla_pag"),false,false,0,"Text10",null,null,null,"")%>
					  <%//=fb.select("cod_planilla_pag"+i,"1=Planilla Quincenal,2=Planilla Décimo,3=Planilla de Vacaciones,5=Planilla de Bonificaciones,6=Planilla de Incentivos,7=Planilla de Ajuste,8=Planilla Liquidaciones,9=Participación en Utilidades",cdos.getColValue("cod_planilla_pag"),false,false,0,"Text10",null,null)%></td>
                    </tr>
                  </table></td>
              </tr>

              <%}  } %>
            </table></td>
        </tr>
        <tr class="TextRow02">
          <td align="right" colspan="4"> Opciones de Guardar: <%//=fb.radio("saveOption","N")%><%=fb.radio("saveOption","O")%>Mantener Abierto <%=fb.radio("saveOption","C",true,false,false)%>Cerrar <%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
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
      </table></td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else if(request.getMethod().equalsIgnoreCase("POST"))
{
String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction = request.getParameter("baction");

ArrayList list= new ArrayList();
desclastLineNo= Integer.parseInt(request.getParameter("desclastLineNo"));
int keySize=Integer.parseInt(request.getParameter("keySize"));
String itemRemoved="";

htdesc.clear();
for(int a=0; a<keySize; a++)
{
 CommonDataObject cdo = new CommonDataObject();
  cdo.setTableName("tbl_pla_t_extraordinario");
  cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and estado_pag ='PE' and emp_id="+emp_id+" and trunc(fecha_inicio)=to_date('"+request.getParameter("fecha_inicio"+a)+"','dd/mm/yyyy') and codigo ="+request.getParameter("codigo"+a));
  cdo.addColValue("emp_id",emp_id);
  cdo.addColValue("provincia",prov);
  cdo.addColValue("sigla",sig);
  cdo.addColValue("tomo",tom);
  cdo.addColValue("asiento",asi);
  cdo.addColValue("compania",(String) session.getAttribute("_companyId"));

 	cdo.addColValue("the_codigo",request.getParameter("the_codigo"+a));
	cdo.addColValue("fecha_inicio", request.getParameter("fecha_inicio"+a));
	cdo.addColValue("saldo",request.getParameter("saldo"+a));
	cdo.addColValue("cantidad",request.getParameter("cantidad"+a));
	//cdo.addColValue("aprobado", request.getParameter("aprobado"+a));
	cdo.addColValue("comentario", request.getParameter("comentario"+a));
	cdo.addColValue("forma_pago", request.getParameter("forma_pago"+a));
	cdo.addColValue("anio_pag", request.getParameter("anio_pag"+a));
	//cdo.addColValue("mes_pago", request.getParameter("mes_pago"+a));
	cdo.addColValue("quincena_pag", request.getParameter("quincena_pag"+a));
	cdo.addColValue("cod_planilla_pag", request.getParameter("cod_planilla_pag"+a));
	//cdo.addColValue("estado_pag","PE"); se agrega el estado "AN" para anular transacciones
	cdo.addColValue("estado_pag",request.getParameter("estado_pag"+a));
	//cdo.addColValue("fecha_pago",request.getParameter("fecha_pago"+a));
	cdo.addColValue("cantidad_aprob",request.getParameter("cantidad_aprob"+a));
	cdo.addColValue("monto",request.getParameter("monto"+a));
	cdo.addColValue("vobo_estado","N");
  cdo.addColValue("aprobado","S");
	if(request.getParameter("tipoextDesc"+a)!=null && !request.getParameter("tipoextDesc"+a).equals("")) cdo.addColValue("tipoextDesc", request.getParameter("tipoextDesc"+a));
	if(request.getParameter("usuario_creacion"+a)!=null && !request.getParameter("usuario_creacion"+a).trim().equals(""))cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+a));
	else cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
	if(request.getParameter("fecha_creacion"+a)!=null && !request.getParameter("fecha_creacion"+a).trim().equals(""))cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+a));
	else cdo.addColValue("fecha_creacion",cDateTime);
	cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion",cDateTime);

  cdo.addColValue("codigo",request.getParameter("codigo"+a));
  cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId")+" and emp_id="+request.getParameter("emp_id") );
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
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&emp_id="+emp_id+"&desclastLineNo="+desclastLineNo+"&anio_pago="+anio_pago+"&quincena_pago="+quincena_pago+"&fp="+fp);
return;
}

if(request.getParameter("btnagregar")!=null)
{
CommonDataObject cdo = new CommonDataObject();
cdo.addColValue("the_codigo","");
cdo.addColValue("codigo","0");
cdo.addColValue("fecha_inico","");
cdo.addColValue("fecha_creacion",cDateTime);
cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
cdo.addColValue("fecha_inicio",cDateTime.substring(0,10));
cdo.setAction("I");
cdo.setKey(htdesc.size() + 1);
htdesc.put(cdo.getKey(),cdo);
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&emp_id="+emp_id+"&desclastLineNo="+desclastLineNo+"&anio_pago="+anio_pago+"&quincena_pago="+quincena_pago+"&fp="+fp);
 return;
}

if(list.size()==0)
{
	CommonDataObject cdo = new CommonDataObject();
	  cdo.setTableName("tbl_pla_t_extraordinario");
	  cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+"  and estado_pag ='PE' and emp_id="+emp_id);
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
	if (fp.equals("liquidacion")){
	%>
	window.opener.getPlaLiqDLTotales();
	//window.opener.reloadPage('TRX');
	<%
	} else {
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/registro_sobretiempo_list.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/registro_sobretiempo_list.jsp")%>';
<%
		}
		else
		{
%>
	//window.opener.location = '<%=request.getContextPath()%>/rhplanilla/registro_sobretiempo_list.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>&emp_id=<%=emp_id%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
