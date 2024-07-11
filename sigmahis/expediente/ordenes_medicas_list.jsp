<%//@page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.XMLReader"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="xmlRdr" scope="page" class="issi.admin.XMLReader"/>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String compania = (String) session.getAttribute("_companyId");
String fDate = request.getParameter("fDate")==null?"":request.getParameter("fDate");
String tDate = request.getParameter("tDate")==null?"":request.getParameter("tDate");
String ejecutado = request.getParameter("ejecutado")==null?"":request.getParameter("ejecutado");
String estadoOrden = request.getParameter("estado_orden")==null?"":request.getParameter("estado_orden");
String tipoOrden = request.getParameter("tipo_orden")==null?"":request.getParameter("tipo_orden");
String pacId = request.getParameter("pac_id")==null?"":request.getParameter("pac_id");
String noAdmision = request.getParameter("no_admision")==null?"":request.getParameter("no_admision");
String fg = request.getParameter("fg")==null?"":request.getParameter("fg");
String seccion = request.getParameter("seccion")==null?"":request.getParameter("seccion");
String desc = request.getParameter("desc")==null?"":request.getParameter("desc");
String interfaz = request.getParameter("interfaz")==null?"":request.getParameter("interfaz");
String beginSearch = request.getParameter("beginSearch"); 
String categoria = request.getParameter("categoria")==null?"":request.getParameter("categoria");
String exp = request.getParameter("exp")==null?"":request.getParameter("exp");

if (!fg.trim().equalsIgnoreCase("exp_seccion")){
    //if (fDate.equals("")) fDate = cDate.substring(0,10);
    //if (tDate.equals("")) tDate = cDate.substring(0,10);

   // if (request.getParameter("tipo_orden") == null ) tipoOrden = "2";
} else beginSearch = "";

if (exp == null) exp = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null)
  {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
    }
    
    StringBuffer sb = new StringBuffer();
  
	sb.append("select to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am') as fechaSolicitud, t.descripcion as tipoOrden, decode(a.tipo_orden,3,'DIETA - '||x.nombre||'  '||decode(a.nombre,null,' ',' - '||a.nombre), 1, a.nombre||decode(a.prioridad,'H','  --> HOY  '||to_char(a.fecha_orden,'dd-mm-yyyy'),'U',' - HOY URGENTE  '||to_char(a.fecha_orden,'dd-mm-yyyy'),'M','  --> MAÑANA '||to_char(a.fecha_orden,'dd-mm-yyyy'),'O','  --> '||to_char(a.fecha_orden,'dd-mm-yyyy')),  7,d.descripcion||' - '||a.observacion,a.nombre) as nombre, a.ejecutado, tipo_orden, decode(a.tipo_orden,2,a.codigo_orden_med,a.orden_med) as orden_med, a.estado_orden, o.medico, m.primer_nombre||' '||m.primer_apellido as nombre_medico, p.nombre_paciente, a.pac_id||'-'||a.secuencia pid, (select descripcion from tbl_sal_desc_estado_ord where estado=a.estado_orden) as estado_orden_desc , decode(a.estado_orden,'O',(select descripcion from tbl_sal_desc_estado_ord where estado=a.estado_orden)||': '||to_char(a.omitir_fecha,'dd/mm/yyyy hh12:mi am') ||' POR: '||a.omitir_usuario||' - '||(select (select comentario_cancela from tbl_cds_detalle_solicitud where orden_med=a.orden_med and tipo_orden=a.tipo_orden and orden_sec = a.codigo and pac_id =a.pac_id and csxp_admi_secuencia=z.adm_root  ) from dual),'') as comentario_ord, decode(a.stat,'Y','STAT','C','CADA 15', 'R','RUTINA','NO') stat, decode(a.primer_orden,'Y','SI','NO') primer_orden,a.dosis_desc, a.cantidad from tbl_sal_detalle_orden_med a, tbl_sal_orden_medica o,tbl_sal_tipo_orden_med t, (select b.codigo||'-'||c.codigo as codigo, b.descripcion||decode(c.descripcion,null,'',' - '||c.descripcion) as nombre from tbl_cds_tipo_dieta b, tbl_cds_subtipo_dieta c where b.codigo=c.cod_tipo_dieta union all select t.codigo||'-', t.descripcion from tbl_cds_tipo_dieta t ) x, tbl_sal_orden_salida d, tbl_adm_admision z, tbl_adm_medico m, vw_adm_paciente p where z.pac_id=a.pac_id and z.secuencia=a.secuencia and a.tipo_orden=t.codigo(+) and a.tipo_dieta||'-'||a.cod_tipo_dieta=x.codigo(+) and a.cod_salida=d.codigo(+) and a.orden_med = o.codigo and a.secuencia = o.secuencia and a.pac_id = o.pac_id and o.medico = m.codigo and p.pac_id = a.pac_id ");
	
	if (estadoOrden.trim().equals("")){ sb.append(" and ((a.omitir_orden='N' and a.estado_orden='A') or (a.ejecutado='N' and a.estado_orden='S')) ");}
    
    if (!categoria.trim().equals("")){
          sb.append(" and z.categoria = ");
          sb.append(categoria);
        }
        
        if (!pacId.trim().equals("")){
          sb.append(" and a.pac_id = ");
          sb.append(pacId);
        }
        
        if (!noAdmision.trim().equals("")){
          sb.append(" and z.adm_root = ");
          sb.append(noAdmision);
        }
     if (fg.trim().equalsIgnoreCase("exp_seccion")){    
        if (!interfaz.equals("")){
            sb.append(" and a.centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz = '");
            sb.append(interfaz);
            sb.append("')");
        }
    
    }
    
    if (!fg.trim().equalsIgnoreCase("exp_seccion")){
        if (!fDate.trim().equals("") && !tDate.trim().equals("")) {
          sb.append(" and trunc(a.fecha_creacion) between to_date('");
          sb.append(fDate);
          sb.append("','dd/mm/yyyy') and to_date('");
          sb.append(tDate);
          sb.append("','dd/mm/yyyy') ");
        }
    }
    
    if (!ejecutado.trim().equals("")){
      sb.append(" and a.ejecutado = '");
      sb.append(ejecutado);
      sb.append("'");
    }
    
    if (!estadoOrden.trim().equals("")){
      sb.append(" and a.estado_orden = '");
      sb.append(estadoOrden);
      sb.append("'");
    }
    
    if (!tipoOrden.trim().equals("")){
      sb.append(" and a.tipo_orden = ");
      sb.append(tipoOrden);
    }
    
    sb.append(" order by t.descripcion, a.fecha_creacion desc ");
    
    if (fg.equalsIgnoreCase("exp_seccion")){
      sb.append(" ,a.orden_med");
    }
	
	if ( beginSearch != null ){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sb+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from("+sb+") ");
	}

	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";
	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

   int nVal, pVal;
   int preVal=Integer.parseInt(previousVal);
   int nxtVal=Integer.parseInt(nextVal);
   if (nxtVal<=rowCount) nVal=nxtVal;
   else nVal=rowCount;
   if(rowCount==0) pVal=0;
   else pVal=preVal;
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script>
document.title = 'ORDENES MEDICAS - '+document.title;

function printList(){
    var pDesde = $("#fDate").val() || '01/01/1900';
    var pHasta = $("#tDate").val() || '01/01/1900';
    var pEjecutado = $("#ejecutado").val() || 'ALL';
    var pTipoOrden = $("#tipo_orden").val() || '<%=(tipoOrden.equals("")?"ALL":tipoOrden)%>';
    var pEstadoOrden = $("#estado_orden").val() || 'ALL';
	var categoria = $("#categoria").val() || 'ALL'; 
        
    abrir_ventana1('../cellbyteWV/report_container.jsp?reportName=expediente/rpt_ordenes_medicas.rptdesign&pPacId=<%=(pacId.equals("")?"0":pacId)%>&pNoAdmision=<%=(noAdmision.equals("")?"0":noAdmision)%>&pDesde='+pDesde+'&pHasta='+pHasta+'&pEjecutado='+pEjecutado+'&pTipoOrden='+pTipoOrden+'&pCtrlHeader=false&pEstadoOrden='+pEstadoOrden+'&pInterfaz=<%=(interfaz.equals("")?"ALL":interfaz)%>&pCategoria='+categoria+'&pExp=<%=exp%>');
}

function printOrden(id, tipoOrden){
   switch(tipoOrden){
     case 1:
        abrir_ventana('../expediente/print_exp_seccion_19.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&interfaz=<%=interfaz%>&cod_orden='+id); break;
     case 2:
        abrir_ventana('../expediente/print_exp_seccion_5.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&interfaz=<%=interfaz%>&noOrden='+id+'&exp=<%=exp%>'); break;
     case 3:
        abrir_ventana('../expediente/print_exp_seccion_37.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&interfaz=<%=interfaz%>&idOrden='+id); break;
     case 6:
        abrir_ventana('../expediente/print_exp_seccion_30.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&interfaz=<%=interfaz%>&id='+id); break;
     case 8:
        abrir_ventana('../expediente/print_list_ordenmedica.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&interfaz=<%=interfaz%>&idOrden='+id+'&fg=<%=fg%>'); break;
    case 12:
        abrir_ventana('../expediente/print_exp_seccion_23.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&interfaz=<%=interfaz%>&code='+id+'&fg=<%=fg%>'); break;
   }
}
$(function(){
  $(".observAyuda").tooltip({
	content: function () {

	  var $i = $(this).data("i");
	  var $type = $(this).data("type");
	  var $title = $($(this).prop('title'));
	  var $content;	 	  
	  if($type == "1" ) $content = $("#observAyudaCont"+$i).val(); 
	  var $cleanContent = $($content).text();
	  if (!$cleanContent) $content = "";
	  return $content;
	}
	,track: true
	,position: { my: "left+15 center", at: "right center", collision: "flipfit" }
  });
});

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - ORDENES MEDICAS"></jsp:param>
</jsp:include>
<table width="99%" cellpadding="1" cellspacing="0">
  <tr class="TextRow02">
    <td align="right">&nbsp;</td>
  </tr>
  <%if (!fg.trim().equalsIgnoreCase("exp_seccion")){%>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextFilter">
			
					<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("beginSearch","")%>
					<td colspan="2">
						<cellbytelabel>Ejecutado</cellbytelabel>
						<%=fb.select("ejecutado","S=SI, N=NO",ejecutado,"T")%>
                        &nbsp;
                        <cellbytelabel id="14">Fecha Solicitud</cellbytelabel>
                        <jsp:include page="../common/calendar.jsp" flush="true">
                        <jsp:param name="noOfDateTBox" value="2" />
                        <jsp:param name="nameOfTBox1" value="fDate" />
                        <jsp:param name="valueOfTBox1" value="<%=fDate%>" />
                        <jsp:param name="nameOfTBox2" value="tDate" />
                        <jsp:param name="valueOfTBox2" value="<%=tDate%>" />
                        <jsp:param name="clearOption" value="true" />
                        </jsp:include>
                        &nbsp;Estado                        
                        <%=fb.select(ConMgr.getConnection(),"select estado, descripcion from tbl_sal_desc_estado_ord","estado_orden",estadoOrden,false,false,0,null,null,null,null,"T")%>
                        &nbsp;
                        
                        Tipo Orden
                        <%=fb.select(ConMgr.getConnection(),"select codigo, codigo||' - '||descripcion from tbl_sal_tipo_orden_med","tipo_orden",tipoOrden,false,false,0,null,null,null,null,"T")%>
                        <br>
						Id Pac: <%=fb.textBox("pac_id",pacId,false,false,false,7,null,null,"")%>&nbsp;&nbsp;
						NO. ADM <%//=fb.textbox("no_admision",noAdmision,false,false,false,60,null,null,"")%> 
						<%=fb.textBox("no_admision",noAdmision,false,false,false,5,null,null,"")%>
							
							<cellbytelabel id="2">Categor&iacute;a</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_adm_categoria_admision","categoria",categoria,false,false,0,null,null,null,null,"T")%>	
                        &nbsp;
						<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
    <%}%>
    <tr class="TextRow02">
      <td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype></td>
    </tr>
</table>
<%if (!fg.trim().equalsIgnoreCase("exp_seccion")){%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
				<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("ejecutado",ejecutado)%>
				<%=fb.hidden("estadoOrden",estadoOrden)%>
				<%=fb.hidden("tipoOrden",tipoOrden)%>
				<%=fb.hidden("seccion",seccion)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("desc",desc)%>
				<%=fb.hidden("pac_id",pacId)%>
				<%=fb.hidden("no_admision",noAdmision)%>
				<%=fb.hidden("interfaz",interfaz)%>
                               
                <td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
				<%fb=new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("ejecutado",ejecutado)%>
				<%=fb.hidden("estadoOrden",estadoOrden)%>
				<%=fb.hidden("tipoOrden",tipoOrden)%>
                <%=fb.hidden("fg",fg)%>
				<%=fb.hidden("desc",desc)%>
				<%=fb.hidden("pac_id",pacId)%>
				<%=fb.hidden("no_admision",noAdmision)%>
                <%=fb.hidden("interfaz",interfaz)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<%}%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader">
			<td width="<%=exp.equals("3")?"19%":"20%"%>"><cellbytelabel>Paciente</cellbytelabel></td>
			<td width="<%=exp.equals("3")?"15%":"20%"%>"><cellbytelabel>M&eacute;dico</cellbytelabel></td>
			
			<td width="<%=exp.equals("3")?"19%":"20%"%>"><cellbytelabel>Orden</cellbytelabel></td>
			<%if(exp.equals("3")){%><td width="5%"><cellbytelabel>Dosis</cellbytelabel></td><%}%>
			<td width="10%" align="center"><cellbytelabel>Fecha Creac.</cellbytelabel></td>
			<td width="7%" align="center"><cellbytelabel>Ejecutado?</cellbytelabel></td>
			<td width="<%=exp.equals("3")?"7%":"10%"%>" align="center"><cellbytelabel>Estado</cellbytelabel></td>
            <%if(exp.equals("3")){%>
                <td align="center" width="3%">STAT</td>
                <td align="center" width="5%">1er Orden</td>
            <%}%>
		</tr>
		<%
        String grp1 = "", grp2 = "";
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) al.get(i);
			String color = "TextRow02";
			if (i % 2 == 0) color = "TextRow01";
            

            if (!grp1.equals(cdo.getColValue("tipoorden"))){
        %>   
                <tr class="TextHeader">
                  <td colspan="<%=exp.equals("3")?"9":"6"%>"><%=cdo.getColValue("tipoorden","")%></td>
                </tr>
        <%   
            }
            if (fg.equalsIgnoreCase("exp_seccion")){
                if (!grp2.equals(cdo.getColValue("orden_med"))){
                %>   
                    <tr class="TextHeader">
                      <td colspan="<%=exp.equals("3")?"8":"5"%>">Orden#: <%=cdo.getColValue("orden_med")%></td>
                      <td align="center">
                      <a href="javascript:printOrden(<%=cdo.getColValue("orden_med")%>,<%=tipoOrden%>)" class="Link04Bold">Imprimir</a></td>
                    </tr>
                <%   
                }
            }
	    %>
		<%//=fb.hidden("observAyudaCont"+i,"<label class='observAyudaCont' style='font-size:11px'>"+(cdo.getColValue("comentario_ord")==null?"":cdo.getColValue("comentario_ord"))+"</label>")%>
        <input type="hidden" name="observAyudaCont<%=i%>" id="observAyudaCont<%=i%>" value="<label class='observAyudaCont' style='font-size:11px'><%=(cdo.getColValue("comentario_ord")==null?"":cdo.getColValue("comentario_ord"))%></label>">
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td>[<%=cdo.getColValue("pid")%>]&nbsp;<%=cdo.getColValue("nombre_paciente")%></td>
			<td>[<%=cdo.getColValue("medico")%>]&nbsp;<%=cdo.getColValue("nombre_medico")%></td>
			<td>
            <%if(!fg.equalsIgnoreCase("exp_seccion")){%>[<%=cdo.getColValue("orden_med")%>]&nbsp;
            <%}%>
            <%=cdo.getColValue("nombre")%>
            <%if(!cdo.getColValue("cantidad"," ").trim().equals("")){%>
            &nbsp;<b>##<%=cdo.getColValue("cantidad")%></b>
            <%}%>
            </td>
			<%if(exp.equals("3")){%><td><%=cdo.getColValue("dosis_desc")%></td><%}%>
			<td><%=cdo.getColValue("fechaSolicitud")%></td>
			<td align="center"><%=cdo.getColValue("ejecutado")%></td>
			<td align="center"><span class="observAyuda" title="" data-i="<%=i%>" data-type="1"><%=cdo.getColValue("estado_orden_desc")%></td>
            
            <%if(exp.equals("3")){%>
                <td align="center"><%=cdo.getColValue("stat")%></td>
                <td align="center"><%=cdo.getColValue("primer_orden")%></td>
            <%}%>
            
		</tr>
		<%
          grp1 = cdo.getColValue("tipoorden");
          grp2 = cdo.getColValue("orden_med");
        }%>
		</table>
	</td>
</tr>
</table>
<%if (!fg.trim().equalsIgnoreCase("exp_seccion")){%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
				<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("ejecutado",ejecutado)%>
				<%=fb.hidden("estadoOrden",estadoOrden)%>
				<%=fb.hidden("tipoOrden",tipoOrden)%>
                <%=fb.hidden("fg",fg)%>
				<%=fb.hidden("desc",desc)%>
				<%=fb.hidden("pac_id",pacId)%>
				<%=fb.hidden("no_admision",noAdmision)%>
                <%=fb.hidden("interfaz",interfaz)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
				<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("ejecutado",ejecutado)%>
				<%=fb.hidden("estadoOrden",estadoOrden)%>
				<%=fb.hidden("tipoOrden",tipoOrden)%>
                <%=fb.hidden("fg",fg)%>
				<%=fb.hidden("desc",desc)%>
				<%=fb.hidden("pac_id",pacId)%>
				<%=fb.hidden("no_admision",noAdmision)%>
                <%=fb.hidden("interfaz",interfaz)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<%}%>
</body>
</html>
<%
}
%>