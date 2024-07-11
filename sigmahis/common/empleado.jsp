<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.rhplanilla.Empleado"%>
<%@ page import="issi.rhplanilla.Vacaciones"%>
<%@ page import="issi.rhplanilla.TemporalVac"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.CommonDataObject" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="EmplMgr" scope="page" class="issi.rhplanilla.VacacionesMgr" />
<jsp:useBean id="del" scope="page" class="issi.rhplanilla.Empleado" />
<jsp:useBean id="DI" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />

<%
/**
==================================================================================
==================================================================================
**/
SQLMgr.setConnection(ConMgr);
String change = request.getParameter("change");
String key = "";
StringBuffer sql = new StringBuffer();
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String empId = request.getParameter("empId");
if(fp==null) fp="";
if(empId==null) empId = "";
boolean viewMode = false;


if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

 
			if(!empId.trim().equals("")){
				sql.append("select a.compania, a.emp_id empId, a.provincia, a.sigla, a.tomo, a.asiento ,a.nombre_empleado nombreEmpleado,a.num_empleado numEmpleado,a.salario_base salarioMes,a.unidad_organi unidad,(select descripcion from tbl_sec_unidad_ejec where codigo =a.unidad_organi and compania =a.compania)unidadDesc, nvl(mod(trunc(months_between(sysdate, a.fecha_ingreso)), 12), 0)  meses,nvl(trunc(months_between(sysdate, a.fecha_ingreso) / 12), 0) anios,(select denominacion from tbl_pla_cargo where codigo =a.cargo and compania = a.compania) descCargo,a.cargo,to_char(a.fecha_ingreso,'dd/mm/yyyy') as fechaIngreso,round(a.rata_hora,2) as rata_hora,nvl(a.gasto_rep,0)gasto_rep, nvl(a.num_ssocial, ' ')num_ssocial, a.tipo_renta, a.num_dependiente, a.ubic_seccion grupo,round((nvl(a.gasto_rep, 0) / (select d.cant_horas_mes from tbl_pla_horario_trab d where  d.codigo=a.horario and d.compania = a.compania)), 2) rata_horagr from vw_pla_empleado a where compania =");
				sql.append((String) session.getAttribute("_companyId"));
				sql.append(" and emp_id = ");
				sql.append(empId);
	
	cdo = SQLMgr.getData(sql.toString());
	
}//empId
else{cdo = new CommonDataObject();
		cdo.addColValue("salarioMes","0");}	
		if (cdo == null)
	{
		cdo = new CommonDataObject();
		cdo.addColValue("salarioMes","0");
	}
%>
<script language="javascript">
function selEmpleado(){
	abrir_ventana1('../common/search_empleado.jsp?fp=empleado&fg=<%=fg%>');
}
function setEmpleadoInfo(formName)
{
	if(formName!=undefined)
	{
		document.forms[formName].provincia.value=document.empleado.provincia.value;
		document.forms[formName].sigla.value=document.empleado.sigla.value;
		document.forms[formName].tomo.value=document.empleado.tomo.value;
		document.forms[formName].asiento.value=document.empleado.asiento.value;
		document.forms[formName].empId.value=document.empleado.empId.value;
		if(document.forms[formName].fechaIngreso)document.forms[formName].fechaIngreso.value=document.empleado.fechaIngreso.value;
		if(document.forms[formName].num_empleado)document.forms[formName].num_empleado.value=document.empleado.num_empleado.value;
		if(document.forms[formName].salario)document.forms[formName].salario.value=document.empleado.salario_mes.value;
		if(document.forms[formName].rataHora)document.forms[formName].rataHora.value=document.empleado.rata_hora.value;
		if(document.forms[formName].gastoRep)document.forms[formName].gastoRep.value=document.empleado.gasto_rep.value;
		if(document.forms[formName].grupo)document.forms[formName].grupo.value=document.empleado.grupo.value;
		if(document.forms[formName].rata_horagr)document.forms[formName].rata_horagr.value=document.empleado.rata_horagr.value;
		
	}
}
</script>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder">
      <table align="center" width="100%" cellpadding="0" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
	  <%fb = new FormBean("empleado",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
      <%=fb.formStart(true)%>
      <%=fb.hidden("mode",mode)%>
      <%=fb.hidden("baction","")%>
      <%=fb.hidden("errCode","")%>
      <%=fb.hidden("errMsg","")%>
      <%=fb.hidden("fg",fg)%>
      <%=fb.hidden("fp",fp)%>
      <%=fb.hidden("clearHT","")%>
	  <%=fb.hidden("grupo",""+cdo.getColValue("grupo"))%>
	  <%=fb.hidden("rata_horagr",""+cdo.getColValue("rata_horagr"))%>
	  
        <tr class="TextPanel">
          <td colspan="4"><cellbytelabel>DATOS DEL EMPLEADO</cellbytelabel></td>
        </tr>
        <tr class="TextRow01">
          <td><cellbytelabel>Empleado</cellbytelabel></td>
          <td colspan="3">
          <%//=fb.hidden("empId",cdo.getColValue("empId"))%>
          <%=fb.textBox("nombre",cdo.getColValue("nombreEmpleado"),false,false,true,50)%>
		  <%=fb.textBox("provincia",cdo.getColValue("provincia"),false,false,true,2)%>-
          <%=fb.textBox("sigla",cdo.getColValue("sigla"),false,false,true,3)%>-
          <%=fb.textBox("tomo",cdo.getColValue("tomo"),false,false,true,5)%>-
          <%=fb.textBox("asiento",cdo.getColValue("asiento"),false,false,true,5)%>
          <%=fb.button("buscar","...",false,(viewMode||!mode.trim().equals("add")),"","","onClick=\"javascript:selEmpleado()\"")%></td>
        </tr>   
        <tr class="TextRow01">
          <td><cellbytelabel>No. Empleado</cellbytelabel></td>
          <td><%=fb.textBox("num_empleado",cdo.getColValue("numEmpleado"),true,false,true,5)%>&nbsp;ID.  <%=fb.textBox("empId",cdo.getColValue("empId"),true,false,true,5)%>
		  &nbsp;<cellbytelabel>Seg. Social</cellbytelabel> <%=fb.textBox("num_ssocial",cdo.getColValue("num_ssocial"),false,false,true,10,"text10","","")%></td>
          <td><cellbytelabel>Salario Base</cellbytelabel>:
		  <%=fb.textBox("salario_mes",(cdo.getColValue("salarioMes")!=null && !cdo.getColValue("salarioMes").trim().equals("")?cdo.getColValue("salarioMes"):""),false,false,true,8)%></td>
          <td><cellbytelabel>Gasto Rep</cellbytelabel>.<%=fb.textBox("gasto_rep",cdo.getColValue("gasto_rep"),false,false,true,8)%>&nbsp;&nbsp;<cellbytelabel>Rata x Hora</cellbytelabel> <%=fb.textBox("rata_hora",cdo.getColValue("rata_hora"),false,false,true,8)%>
		   </td>
        </tr>     
        <tr class="TextRow01" >
          <td><cellbytelabel>Unidad Admin</cellbytelabel>.:</td>
          <td colspan="2">
					<%=fb.textBox("unidad_organi",cdo.getColValue("unidad"),false,false,true,5)%>
          <%=fb.textBox("unidad_organi_desc",cdo.getColValue("unidadDesc"),false,false,true,50)%>          </td>
		  <td>
					<%=fb.textBox("cargo",cdo.getColValue("cargo"),false,false,true,5)%>
          <%=fb.textBox("descCargo",cdo.getColValue("descCargo"),false,false,true,50)%>          </td>
        </tr>
		<tr class="TextRow01" >
          <td><cellbytelabel>Fecha Ingreso</cellbytelabel>:</td>
          <td><%=fb.textBox("fechaIngreso",cdo.getColValue("fechaIngreso"),false,false,true,10)%></td>
		  <td><cellbytelabel>Antiguedad</cellbytelabel>:</td>
		  <td><cellbytelabel>A&ntilde;os</cellbytelabel>:<%=fb.textBox("anio",cdo.getColValue("anios"),false,false,true,10)%>
          <cellbytelabel>Meses</cellbytelabel>:<%=fb.textBox("meses",cdo.getColValue("meses"),false,false,true,10)%></td>
        </tr>
		<tr class="TextRow01">
				<td><cellbytelabel>Clave</cellbytelabel></td>
				<td colspan="3">
        <%=fb.textBox("tipo_renta",cdo.getColValue("tipo_renta"),false,false,true,5,"text10","","")%><cellbytelabel>No. Dependientes</cellbytelabel>
        <%=fb.textBox("num_dependiente",cdo.getColValue("num_dependiente"),false,false,true,5,"text10","","")%>
				</td>
		</tr>
        <%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table>    
    </td>
  </tr>
</table>    