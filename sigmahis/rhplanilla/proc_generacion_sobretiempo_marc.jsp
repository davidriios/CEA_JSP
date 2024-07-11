<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="AEmpMgr" scope="page" class="issi.rhplanilla.AccionesEmpleadoMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="emp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="empKey" scope="session" class="java.util.Hashtable" />

<%
/**
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AEmpMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
emp.clear();
empKey.clear();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String lote = request.getParameter("lote");

String periodo = request.getParameter("anio");
String quincena = request.getParameter("mes");
String cierre = request.getParameter("cierre");
String desde = request.getParameter("desde");
String hasta = request.getParameter("hasta");

String fechaDesde = request.getParameter("fecha_desde");
String fechaHasta = request.getParameter("fecha_hasta");

if(fg==null) fg = "";
if(grupo==null) grupo = "";
if(area==null) area = "";
if(fp==null) fp = "";
if(anio==null) anio = "";
if(mes==null) mes = "";
if(lote==null) lote = "";
if(fechaDesde==null) fechaDesde = "";
if(fechaHasta==null) fechaHasta = "";

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha = cDateTime.substring(0,10);
int lineNo = 0;
if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
/*
	sql="select	to_char(trans_desde,'dd/mm/yyyy') desde, to_char(trans_hasta,'dd/mm/yyyy') hasta, to_char(fecha_cierre,'dd/mm/yyyy') cierre, periodo, decode(substr(fecha_inicial,0,2), '01', 'PRIMERA', '16', 'SEGUNDA') quincena, to_char(fecha_inicial,'yyyy') anio, to_char(sysdate,'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') mes from	tbl_pla_calendario where tipopla = 1 and trunc(fecha_inicial)	<= to_date('"+fecha+"','dd/mm/yyyy') and trunc(fecha_final) >= to_date('"+fecha+"','dd/mm/yyyy')";
	*/

	//  se pone fijo para prueba  periodo 15
	sql="select	to_char(trans_desde,'dd/mm/yyyy') desde, to_char(trans_hasta,'dd/mm/yyyy') hasta, to_char(fecha_cierre,'dd/mm/yyyy') cierre, periodo, decode(substr(fecha_inicial,0,2), '01', 'PRIMERA', '16', 'SEGUNDA') quincena, to_char(fecha_inicial,'yyyy') anio, to_char(sysdate,'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') mes from	tbl_pla_calendario where tipopla = 1 and periodo=15";
	
	
		cdo = SQLMgr.getData(sql);
		if(cdo==null) cdo = new CommonDataObject();
		periodo = cdo.getColValue("periodo");
		anio = cdo.getColValue("anio");
		mes = cdo.getColValue("mes");
		quincena = cdo.getColValue("quincena");
		cierre = cdo.getColValue("cierre");
		desde = cdo.getColValue("desde");
		hasta = cdo.getColValue("hasta");
			//	System.out.println("in...................."||sql);

	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'PLANILLA - '+document.title;

function doAction(){
	setHeight('itemFrame',document.body.scrollHeight);
}

function generar() {
	 $("#baction").val("EJECUTAR");
	 $("#form1").submit();
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="GENERACION DE MARCACION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
        <tr>
          <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
              <tr>
                <td><table align="center" width="100%" cellpadding="0" cellspacing="1">
                    <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
                    <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                    <%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("errCode","")%>
			<%=fb.hidden("errMsg","")%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("clearHT","")%>
                    	<%=fb.hidden("fecha_inicio","")%>
                    	<%=fb.hidden("fecha_final","")%>
                    	<%=fb.hidden("finicio","")%>
                    	<%=fb.hidden("ffinal","")%>
                    	<%=fb.hidden("num_periodo","")%>
                    	<%=fb.hidden("lote", lote)%>
                    	<%=fb.hidden("fecha_desde", fechaDesde)%>
                    	<%=fb.hidden("fecha_hasta", fechaHasta)%>

                    <tr>
                      <td><table width="100%" cellpadding="1" cellspacing="0">
                      
                        
                          <tr class="TextPanel">
                            <td colspan="2">&nbsp;Parámetros para Generación de Sobretiempo</td>
                          </tr>
                        
			  <tr class="TextRow01" align="right">
                            <td colspan="2">&nbsp;Fecha Inicio &nbsp;
				<%=fb.textBox("desde",cdo.getColValue("desde"),true,false,true,10,"text10","","")%>
				&nbsp;&nbsp;
			  </td>
                          </tr>
			    <tr class="TextRow01">
                            <td align="left">&nbsp;
                            No. Periodo :
				<%=fb.textBox("periodo",cdo.getColValue("periodo"),true,false,true,4,"text10","","")%>
				&nbsp;&nbsp; Año :
				<%=fb.textBox("anio",anio,true,false,true,4,"text10","","")%>
                            &nbsp; &nbsp;Mes :
				<%=fb.textBox("mes",mes,true,false,true,14,"text10","","")%>
			    &nbsp;&nbsp; Quincena :
				<%=fb.textBox("quincena",quincena,true,false,true,14,"text10","","")%>
                            </td>
                            <td align="right">&nbsp;Fecha Final &nbsp;
				<%=fb.textBox("hasta",cdo.getColValue("hasta"),true,false,true,10,"text10","","")%>
				&nbsp;&nbsp;
				</td>
                          </tr>
                          <tr class="TextRow01">
                            <td>&nbsp;Grupo :
                           	<%=fb.select(ConMgr.getConnection(),"select codigo as grupo,  codigo||'-'||descripcion descripcion, codigo from tbl_pla_ct_grupo where compania="+(String) session.getAttribute("_companyId")+" order by 1","grupo",grupo,false,false,0,"Text10",null,null,null,"T")%>
                            &nbsp;&nbsp;<%//=fb.button("ir","  Ir  ",false,false,"text10","","onClick=\"javascript:setTextValues();\"")%>
                            &nbsp;&nbsp;
                            Lote: <%=lote%>&nbsp;&nbsp;&nbsp;&nbsp;<b>Marcaci&oacute;n desde: <%=fechaDesde%> hasta: <%=fechaHasta%></b>
                            </td>
                            <td  align="right">&nbsp;Cierre &nbsp;<%=fb.textBox("cierre",cierre,true,false,true,10,"text10","","")%>&nbsp;&nbsp;&nbsp;</td>
                          </tr>

                         	

                        </table></td>
                    </tr>
                    
                    <tr class="TextRow01">
                      <td>&nbsp;</td>
                    </tr>
                    
                    <tr class="TextRow02">
                      <td align="center">
                         <%=fb.button("exec","EJECUTAR",false,!lote.equals("")?false:true,"text10","","onClick=\"javascript:generar();\"")%>
                      </td>
                    </tr>

                    <%=fb.formEnd(true)%>
                    <!-- ================================   F O R M   E N D   H E R E   ================================ -->
                  </table></td>
              </tr>
            </table></td>
        </tr>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
  </tr>
</table>
</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");
	if (saveOption == null) saveOption = "";
	String errCode = "";
	String errMsg = "";
				
	if (request.getParameter("baction").equalsIgnoreCase("EJECUTAR")){
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
    
    cdo = new CommonDataObject();
    
    CommonDataObject cdoH = SQLMgr.getData("select  nvl(max(codigo),0) + 1 as next_id from TBL_PLA_MARC_DIST");
    if (cdoH == null) cdoH = new CommonDataObject();
    
    cdo.setTableName("TBL_PLA_MARC_DIST");
    cdo.addColValue("codigo", cdoH.getColValue("next_id"));
    cdo.addColValue("grupo", request.getParameter("grupo"));
    cdo.addColValue("lote", request.getParameter("lote"));
    cdo.addColValue("periodo", request.getParameter("periodo"));
    cdo.addColValue("anio", request.getParameter("anio"));
    cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
    cdo.addColValue("fecha_creacion", cDateTime);
    cdo.addColValue("fecha_modificacion", cDateTime);
    cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
    cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
    
    StringBuffer sbSql = new StringBuffer();
	
	sbSql.append("select  z.grupo, 'TOTHE125' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'TOTHE125' and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and z.grupo = ");
	sbSql.append(request.getParameter("grupo")); 

	sbSql.append(" and a.lote = ");
	sbSql.append(request.getParameter("lote"));
 
    sbSql.append(" union all ");
	
	sbSql.append("select  z.grupo, 'TOTHE150' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'TOTHE150' and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and z.grupo = ");
	sbSql.append(request.getParameter("grupo")); 
	    
	sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));

    sbSql.append(" union all ");
    
     	sbSql.append("select  z.grupo, 'TOTHE175' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'TOTHE175' and a.compania = ");
        sbSql.append(session.getAttribute("_companyId"));
        sbSql.append(" and z.grupo = ");
        sbSql.append(request.getParameter("grupo")); 
    	    
        sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    	
    sbSql.append(" union all ");
	    
 	sbSql.append("select  z.grupo, 'HEDOMDIURNO' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'HEDOMDIURNO' and a.compania = ");
        sbSql.append(session.getAttribute("_companyId"));
        sbSql.append(" and z.grupo = ");
        sbSql.append(request.getParameter("grupo")); 
	   	    
        sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote")); 
    	
    sbSql.append(" union all ");
	    
 	sbSql.append("select  z.grupo, 'EXCMAS3DIURNO' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'EXCMAS3DIURNO' and a.compania = ");
        sbSql.append(session.getAttribute("_companyId"));
        sbSql.append(" and z.grupo = ");
        sbSql.append(request.getParameter("grupo")); 
	   	    
        sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    
    sbSql.append(" union all ");
    	    
     	sbSql.append("select  z.grupo, 'HEDOMMIXTD/N' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'HEDOMMIXTD/N' and a.compania = ");
        sbSql.append(session.getAttribute("_companyId"));
        sbSql.append(" and z.grupo = ");
        sbSql.append(request.getParameter("grupo")); 
    	   	    
        sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    	
    sbSql.append(" union all ");
		    
	sbSql.append("select  z.grupo, 'HEDOMNOCTUR' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'HEDOMNOCTUR' and a.compania = ");
        sbSql.append(session.getAttribute("_companyId"));
        sbSql.append(" and z.grupo = ");
        sbSql.append(request.getParameter("grupo")); 
		   	    
        sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    	
    sbSql.append(" union all ");
		    
 	sbSql.append("select  z.grupo, 'TOTHENAC' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'TOTHENAC' and a.compania = ");
        sbSql.append(session.getAttribute("_companyId"));
        sbSql.append(" and z.grupo = ");
        sbSql.append(request.getParameter("grupo")); 
		   	    
        sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    	
    sbSql.append(" union all ");
			    
	sbSql.append("select  z.grupo, 'EXCMAS3NOCT' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'EXCMAS3NOCT' and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and z.grupo = ");
	sbSql.append(request.getParameter("grupo")); 
			   	    
	sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    	
    sbSql.append(" union all ");
			    
	sbSql.append("select  z.grupo, 'HEDOMMIXTN/D' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'HEDOMMIXTN/D' and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and z.grupo = ");
	sbSql.append(request.getParameter("grupo")); 
			   	    
	sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    	
    sbSql.append(" union all ");
			    
	sbSql.append("select  z.grupo, 'EXCMAS3MIXTD/N' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'EXCMAS3MIXTD/N' and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and z.grupo = ");
	sbSql.append(request.getParameter("grupo")); 
			   	    
	sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    	
    sbSql.append(" union all ");
  			    
  	sbSql.append("select  z.grupo, 'EXCMAS3MIXTN/D' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'EXCMAS3MIXTN/D' and a.compania = ");
  	sbSql.append(session.getAttribute("_companyId"));
  	sbSql.append(" and z.grupo = ");
  	sbSql.append(request.getParameter("grupo")); 
  			   	    
  	sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    	
    sbSql.append(" union all ");
			    
	sbSql.append("select  z.grupo, 'EXTNACDIURNO' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'EXTNACDIURNO' and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and z.grupo = ");
	sbSql.append(request.getParameter("grupo")); 
			   	    
	sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    	
    sbSql.append(" union all ");
			    
	sbSql.append("select  z.grupo, 'EXCMAS3DOMDIURNO' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'EXCMAS3DOMDIURNO' and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and z.grupo = ");
	sbSql.append(request.getParameter("grupo")); 
			   	    
	sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    	
    sbSql.append(" union all ");
			    
	sbSql.append("select  z.grupo, 'EXTNACMIXTD/N' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'EXTNACMIXTD/N' and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and z.grupo = ");
	sbSql.append(request.getParameter("grupo")); 
			   	    
	sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    	
    sbSql.append(" union all ");
			    
	sbSql.append("select  z.grupo, 'EXTNACNOCTUR' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'EXTNACNOCTUR' and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and z.grupo = ");
	sbSql.append(request.getParameter("grupo")); 
			   	    
	sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    	
     sbSql.append(" union all ");
 			    
 	sbSql.append("select  z.grupo, 'EXCMAS3DOMMIXTD/N' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'EXCMAS3DOMMIXTD/N' and a.compania = ");
 	sbSql.append(session.getAttribute("_companyId"));
 	sbSql.append(" and z.grupo = ");
 	sbSql.append(request.getParameter("grupo")); 
 			   	    
 	sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    
        sbSql.append(" union all ");
    			    
    	sbSql.append("select  z.grupo, 'EXCMAS3DOMNOCTUR' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'EXCMAS3DOMNOCTUR' and a.compania = ");
    	sbSql.append(session.getAttribute("_companyId"));
    	sbSql.append(" and z.grupo = ");
    	sbSql.append(request.getParameter("grupo")); 
    			   	    
    	sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    	
    sbSql.append(" union all ");
				    
	sbSql.append("select  z.grupo, 'EXTNACMIXTN/D' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'EXTNACMIXTN/D' and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and z.grupo = ");
	sbSql.append(request.getParameter("grupo")); 
				   	    
	sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    	
    sbSql.append(" union all ");
				    
	sbSql.append("select  z.grupo, 'EXCMAS3DOMMIXTN/D' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'EXCMAS3DOMMIXTN/D' and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and z.grupo = ");
	sbSql.append(request.getParameter("grupo")); 
				   	    
	sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    	
    sbSql.append(" union all ");
				    
	sbSql.append("select  z.grupo, 'EXCMAS3NACDIURNO' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'EXCMAS3NACDIURNO' and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and z.grupo = ");
	sbSql.append(request.getParameter("grupo")); 
				   	    
	sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
   
    sbSql.append(" union all ");
					    
	sbSql.append("select  z.grupo, 'EXCMAS3NACD/N' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'EXCMAS3NACD/N' and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and z.grupo = ");
	sbSql.append(request.getParameter("grupo")); 
					   	    
	sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    	
    sbSql.append(" union all ");
					    
	sbSql.append("select  z.grupo, 'EXCMAS3NACNOCTUR' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'EXCMAS3NACNOCTUR' and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and z.grupo = ");
	sbSql.append(request.getParameter("grupo")); 
			   	    
	sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
    	
    sbSql.append(" union all ");
					    
	sbSql.append("select  z.grupo, 'EXCMAS3NACN/D' as detalle_factor, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.emp_id, b.codigo as codigo_factor, b.factor_multi as factor, a.cantidad, 'P' estado,'N' generado, to_char(a.hora_desde,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.hora_hasta,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia_marc as secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.tipo_he = b.codigo and b.detalle_factor = 'EXCMAS3NACN/D' and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and z.grupo = ");
	sbSql.append(request.getParameter("grupo")); 
					   	    
	sbSql.append(" and a.lote = ");
    	sbSql.append(request.getParameter("lote"));
   
    sbSql.append(" union all ");
    
    sbSql.append("select z.grupo, 'RENTDOMINGO' as detalle_factor, to_char(a.entrada, 'dd/mm/yyyy') fecha, a.emp_id, (select codigo from TBL_PLA_T_HORAS_EXT where detalle_factor = 'RENTDOMINGO') codigo_factor, (select factor_multi from TBL_PLA_T_HORAS_EXT where detalle_factor = 'RENTDOMINGO') factor, getCalcHoraRegularExtra(a.entrada,a.salida,a.secuencia,to_date(to_char(a.salida,'dd/mm/yyyy')||' '||to_char(b.hora_salida,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),to_date(to_char(a.entrada,'dd/mm/yyyy')||' '||to_char(b.hora_entrada,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),'RENTDOMINGO',b.codigo) cantidad, 'A' estado,'N' generado, to_char(a.entrada,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.salida,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_marcacion a,tbl_pla_ct_turno b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.turno = b.codigo and a.compania = b.compania and a.salida is not null and a.compania = ");
    sbSql.append(session.getAttribute("_companyId"));
    sbSql.append(" and z.grupo = ");
    sbSql.append(request.getParameter("grupo")); 
    
    
    sbSql.append(" and a.id_lote = ");
    sbSql.append(request.getParameter("lote"));

    sbSql.append(" union all ");
    
    sbSql.append("select z.grupo, 'RSALDOMINGO' as detalle_factor, to_char(a.entrada, 'dd/mm/yyyy') fecha, a.emp_id, (select codigo from TBL_PLA_T_HORAS_EXT where detalle_factor = 'RSALDOMINGO') codigo_factor, (select factor_multi from TBL_PLA_T_HORAS_EXT where detalle_factor = 'RSALDOMINGO') factor, getCalcHoraRegularExtra(a.entrada,a.salida,a.secuencia,to_date(to_char(a.salida,'dd/mm/yyyy')||' '||to_char(b.hora_salida,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),to_date(to_char(a.entrada,'dd/mm/yyyy')||' '||to_char(b.hora_entrada,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),'RSALDOMINGO',b.codigo) cantidad, 'A' estado,'N' generado, to_char(a.entrada,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.salida,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_marcacion a,tbl_pla_ct_turno b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.turno = b.codigo and a.compania = b.compania and a.salida is not null and a.compania = ");
    sbSql.append(session.getAttribute("_companyId"));
    sbSql.append(" and z.grupo = ");
    sbSql.append(request.getParameter("grupo")); 
    
    
    sbSql.append(" and a.id_lote = ");
    sbSql.append(request.getParameter("lote"));
    
    sbSql.append(" union all ");
    
    sbSql.append("select z.grupo, 'RENTNACIONAL' as detalle_factor, to_char(a.entrada, 'dd/mm/yyyy') fecha, a.emp_id, (select codigo from TBL_PLA_T_HORAS_EXT where detalle_factor = 'RENTNACIONAL') codigo_factor, (select factor_multi from TBL_PLA_T_HORAS_EXT where detalle_factor = 'RENTNACIONAL') factor, getCalcHoraRegularExtra(a.entrada,a.salida,a.secuencia,to_date(to_char(a.salida,'dd/mm/yyyy')||' '||to_char(b.hora_salida,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),to_date(to_char(a.entrada,'dd/mm/yyyy')||' '||to_char(b.hora_entrada,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),'RENTNACIONAL',b.codigo) cantidad, 'A' estado,'N' generado, to_char(a.entrada,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.salida,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_marcacion a,tbl_pla_ct_turno b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.turno = b.codigo and a.compania = b.compania and a.salida is not null and a.compania = ");
    sbSql.append(session.getAttribute("_companyId"));
    sbSql.append(" and z.grupo = ");
    sbSql.append(request.getParameter("grupo")); 
    
    
    sbSql.append(" and a.id_lote = ");
    sbSql.append(request.getParameter("lote"));
  
    sbSql.append(" union all ");
    
    sbSql.append("select z.grupo, 'RSALNACIONAL' as detalle_factor, to_char(a.entrada, 'dd/mm/yyyy') fecha, a.emp_id, (select codigo from TBL_PLA_T_HORAS_EXT where detalle_factor = 'RSALNACIONAL') codigo_factor, (select factor_multi from TBL_PLA_T_HORAS_EXT where detalle_factor = 'RSALNACIONAL') factor, getCalcHoraRegularExtra(a.entrada,a.salida,a.secuencia,to_date(to_char(a.salida,'dd/mm/yyyy')||' '||to_char(b.hora_salida,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),to_date(to_char(a.entrada,'dd/mm/yyyy')||' '||to_char(b.hora_entrada,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),'RSALNACIONAL',b.codigo) cantidad, 'A' estado,'N' generado, to_char(a.entrada,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.salida,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_marcacion a,tbl_pla_ct_turno b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.turno = b.codigo and a.compania = b.compania and a.salida is not null and a.compania = ");
    sbSql.append(session.getAttribute("_companyId"));
    sbSql.append(" and z.grupo = ");
    sbSql.append(request.getParameter("grupo")); 
    
    
    sbSql.append(" and a.id_lote = ");
    sbSql.append(request.getParameter("lote"));
    
    sbSql.append(" union all ");
    
    sbSql.append("select z.grupo, '8HREGDOMINGO' as detalle_factor, to_char(a.entrada, 'dd/mm/yyyy') fecha, a.emp_id, (select codigo from TBL_PLA_T_HORAS_EXT where detalle_factor = '8HREGDOMINGO') codigo_factor, (select factor_multi from TBL_PLA_T_HORAS_EXT where detalle_factor = '8HREGDOMINGO') factor, getCalcHoraRegularExtra(a.entrada,a.salida,a.secuencia,to_date(to_char(a.salida,'dd/mm/yyyy')||' '||to_char(b.hora_salida,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),to_date(to_char(a.entrada,'dd/mm/yyyy')||' '||to_char(b.hora_entrada,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),'8HREGDOMINGO',b.codigo) cantidad, 'A' estado,'N' generado, to_char(a.entrada,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.salida,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_marcacion a,tbl_pla_ct_turno b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.turno = b.codigo and a.compania = b.compania and a.salida is not null and a.compania = ");
    sbSql.append(session.getAttribute("_companyId"));
    sbSql.append(" and z.grupo = ");
    sbSql.append(request.getParameter("grupo")); 
    
    
    sbSql.append(" and a.id_lote = ");
    sbSql.append(request.getParameter("lote"));
    
    sbSql.append(" union all ");
    
    sbSql.append("select z.grupo,'8HENTDOMINGO' as detalle_factor, to_char(a.entrada, 'dd/mm/yyyy') fecha, a.emp_id, (select codigo from TBL_PLA_T_HORAS_EXT where detalle_factor = '8HENTDOMINGO') codigo_factor, (select factor_multi from TBL_PLA_T_HORAS_EXT where detalle_factor = '8HENTDOMINGO') factor, getCalcHoraRegularExtra(a.entrada,a.salida,a.secuencia,to_date(to_char(a.salida,'dd/mm/yyyy')||' '||to_char(b.hora_salida,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),to_date(to_char(a.entrada,'dd/mm/yyyy')||' '||to_char(b.hora_entrada,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),'8HENTDOMINGO',b.codigo) cantidad, 'A' estado,'N' generado, to_char(a.entrada,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.salida,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_marcacion a,tbl_pla_ct_turno b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.turno = b.codigo and a.compania = b.compania and a.salida is not null and a.compania = ");
    sbSql.append(session.getAttribute("_companyId"));
    sbSql.append(" and z.grupo = ");
    sbSql.append(request.getParameter("grupo")); 
    
    
    sbSql.append(" and a.id_lote = ");
    sbSql.append(request.getParameter("lote"));
    
    sbSql.append(" union all ");
    
    sbSql.append("select z.grupo, '8HSALDOMINGO' as detalle_factor, to_char(a.entrada, 'dd/mm/yyyy') fecha, a.emp_id, (select codigo from TBL_PLA_T_HORAS_EXT where detalle_factor = '8HSALDOMINGO') codigo_factor, (select factor_multi from TBL_PLA_T_HORAS_EXT where detalle_factor = '8HSALDOMINGO') factor, getCalcHoraRegularExtra(a.entrada,a.salida,a.secuencia,to_date(to_char(a.salida,'dd/mm/yyyy')||' '||to_char(b.hora_salida,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),to_date(to_char(a.entrada,'dd/mm/yyyy')||' '||to_char(b.hora_entrada,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),'8HSALDOMINGO',b.codigo) cantidad, 'A' estado,'N' generado, to_char(a.entrada,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.salida,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_marcacion a,tbl_pla_ct_turno b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.turno = b.codigo and a.compania = b.compania and a.salida is not null and a.compania = ");
    sbSql.append(session.getAttribute("_companyId"));
    sbSql.append(" and z.grupo = ");
    sbSql.append(request.getParameter("grupo")); 
    
    
    sbSql.append(" and a.id_lote = ");
    sbSql.append(request.getParameter("lote"));
    
    sbSql.append(" union all ");
    
    sbSql.append("select z.grupo, '8HNACDOMINGO' as detalle_factor, to_char(a.entrada, 'dd/mm/yyyy') fecha, a.emp_id, (select codigo from TBL_PLA_T_HORAS_EXT where detalle_factor = '8HNACDOMINGO') codigo_factor, (select factor_multi from TBL_PLA_T_HORAS_EXT where detalle_factor = '8HNACDOMINGO') factor, getCalcHoraRegularExtra(a.entrada,a.salida,a.secuencia,to_date(to_char(a.salida,'dd/mm/yyyy')||' '||to_char(b.hora_salida,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),to_date(to_char(a.entrada,'dd/mm/yyyy')||' '||to_char(b.hora_entrada,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),'8HNACDOMINGO',b.codigo) cantidad, 'A' estado,'N' generado, to_char(a.entrada,'dd/mm/yyyy hh12:mi:ss am') hora_desde, to_char(a.salida,'dd/mm/yyyy hh12:mi:ss am') hora_hasta, a.secuencia, (select rata_hora from vw_pla_empleado where emp_id = a.emp_id) rata_x_hora from tbl_pla_marcacion a,tbl_pla_ct_turno b, tbl_pla_ct_empleado z where z.emp_id = a.emp_id and z.compania = a.compania and z.estado = 1 and a.turno = b.codigo and a.compania = b.compania and a.salida is not null and a.compania = ");
    sbSql.append(session.getAttribute("_companyId"));
    sbSql.append(" and z.grupo = ");
    sbSql.append(request.getParameter("grupo")); 
    
    
    sbSql.append(" and a.id_lote = ");
    sbSql.append(request.getParameter("lote"));
    
    al = SQLMgr.getDataList(sbSql.toString());
    
    ArrayList alDet = new ArrayList();
    
    for (int i=0; i<al.size(); i++){
      CommonDataObject data = (CommonDataObject) al.get(i);
      
      if (!data.getColValue("cantidad","0").equals("0")) {
      
        CommonDataObject cdoDet = new CommonDataObject();
        cdoDet.setTableName("TBL_PLA_MARC_DIST_DET");
        
        cdoDet.addColValue("CODIGO_MARC_DIST", cdoH.getColValue("next_id"));
        cdoDet.addColValue("COD_SECUENCIA", "(select nvl(max(COD_SECUENCIA),0)+1 from TBL_PLA_MARC_DIST_DET where emp_id = "+data.getColValue("emp_id")+" and CODIGO_MARC_DIST = "+cdoH.getColValue("next_id")+")");
        cdoDet.addColValue("COMPANIA", (String) session.getAttribute("_companyId"));
        cdoDet.addColValue("UE_CODIGO", data.getColValue("grupo"));
        cdoDet.addColValue("ANIO", request.getParameter("anio"));
        cdoDet.addColValue("PERIODO", request.getParameter("periodo"));
        cdoDet.addColValue("FECHA", data.getColValue("fecha"));
        cdoDet.addColValue("CODIGO", "1");
        cdoDet.addColValue("MARC_SECUENCIA", data.getColValue("secuencia"));
        cdoDet.addColValue("TIPO_HE", data.getColValue("codigo_factor"));
		cdoDet.addColValue("FACTOR", data.getColValue("factor"));
		cdoDet.addColValue("DETALLE_FACTOR", data.getColValue("detalle_factor"));
		cdoDet.addColValue("LOTE", request.getParameter("lote"));
        cdoDet.addColValue("CANTIDAD", data.getColValue("cantidad"));
        cdoDet.addColValue("GENERADO", data.getColValue("generado"));
        cdoDet.addColValue("ESTADO", data.getColValue("estado"));
        cdoDet.addColValue("HORA_DESDE", data.getColValue("hora_desde"));
        cdoDet.addColValue("HORA_HASTA", data.getColValue("hora_hasta"));
        cdoDet.addColValue("TIPO_DETALLE", "E");
        cdoDet.addColValue("EMP_ID", data.getColValue("emp_id"));
		cdoDet.addColValue("fecha_creacion", cDateTime);
		cdoDet.addColValue("fecha_modificacion", cDateTime);
		cdoDet.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		cdoDet.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
        
        cdoDet.setAction("I");
        
        alDet.add(cdoDet);
      
      }
      
	  }//for
	  
	  if (alDet.size() == 0) {
      CommonDataObject cdo2 = new CommonDataObject();

      cdo2.setTableName("TBL_PLA_MARC_DIST_DET");
      cdo2.setWhereClause("SECUENCIA = -1");

      alDet.add(cdo2);
    }

    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
    SQLMgr.save(cdo,alDet,true,true,true,true);
    ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1")){
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	parent.hidePopWin();
<%
	if (saveOption.equalsIgnoreCase("O")){
%>
	setTimeout('addMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("C")){
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&grupo=<%=grupo%>&area=<%=area%>&anio=<%=request.getParameter("anio")%>&mes=<%=request.getParameter("mes")%>&lote=<%=lote%>&fecha_desde=<%=fechaDesde%>&fecha_hasta=<%=fechaHasta%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
