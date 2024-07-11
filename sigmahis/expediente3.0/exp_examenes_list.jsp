<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.expediente.OrdenMedica"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="ELMgr" scope="page" class="issi.expediente.ExamenesLabMgr"/>
<%
/**
==================================================================================
sal310150
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ELMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alM = new ArrayList();
StringBuffer sbSql = new StringBuffer();
boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fp = request.getParameter("fp");
String cds = request.getParameter("cds");
String examen = request.getParameter("examen");
String appendFilter = "";
if(examen == null) examen = "";
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (fp == null) fp = "imagenologia";
//if (cds == null) throw new Exception("El Centro de Servicio no es válido. Por favor intente nuevamente!");
if(!examen.equals("")) appendFilter = " and (upper(a.observacion||' ('||a.codigo||')') like '%"+examen.toUpperCase()+"%' or upper(a.descripcion||' ('||a.codigo||')') like '%"+examen.toUpperCase()+"%')";
String xCds = request.getParameter("xCds");
String xCdsFilter = "", xCdsFilterProfile1="", xCdsFilterProfile2="";
if(xCds!=null && !xCds.equals("")) xCdsFilter = " and c.codigo = " + xCds;
else xCds = "";

int size = 0;
String key = "";
String interfaz ="";
String profileCPT = (request.getParameter("profileCPT")==null?"":request.getParameter("profileCPT"));//profileCPT=0 --> cuando es busqueda por examen de laboratorio
String selectedVal = (request.getParameter("selectedVal")==null?"":request.getParameter("selectedVal"));
String secuenciaCorte = request.getParameter("secuenciaCorte");

if(fp.trim().equals("laboratorio"))interfaz ="LIS";
else if(fp.trim().equals("imagenologia"))interfaz ="RIS";
else if(fp.trim().equals("BDS"))interfaz ="BDS";

// Sin esta acción, cuando se seleccione : SELECCIONE (cds == null),
// la lista de procedimientos seguirá mostrando datos
HashDet.clear();
	
	cdo = SQLMgr.getData("select get_admCorte("+pacId+","+noAdmision+") as secuenciaCorte from dual");
	if (cdo != null) secuenciaCorte = cdo.getColValue("secuenciaCorte");
	if (secuenciaCorte == null || secuenciaCorte.trim().equals("")) secuenciaCorte = noAdmision;


//filtro para sacar los que son parte de un perfil: Adm > Mant > Perfil CPT
if (!profileCPT.trim().equals("") && !profileCPT.equals("0")){
		xCdsFilterProfile1 += " and c.codigo in (select  cds.cod_centro_servicio from tbl_cds_procedimiento_x_cds cds ,tbl_cdc_cpt_x_profiles a where cds.cod_procedimiento = a.id_cpt and cds.cod_centro_servicio = a.cod_cds and a.id_profile = "+profileCPT+" and a.id_cpt=a.codigo)  and b.cod_procedimiento in (select  cds.cod_procedimiento from tbl_cds_procedimiento_x_cds cds ,tbl_cdc_cpt_x_profiles a where cds.cod_procedimiento = a.id_cpt and cds.cod_centro_servicio = a.cod_cds and a.id_profile = "+profileCPT+")";

		xCdsFilterProfile2 += " and c.codigo in (select  cds.cod_centro_servicio from tbl_cds_procedimiento_x_cds cds ,tbl_cdc_cpt_x_profiles a where cds.cod_procedimiento = a.id_cpt and cds.cod_centro_servicio = a.cod_cds and a.id_profile = "+profileCPT+" and a.id_cpt=a.codigo) and a.cpt in (select  cds.cod_procedimiento from tbl_cds_procedimiento_x_cds cds ,tbl_cdc_cpt_x_profiles a where cds.cod_procedimiento = a.id_cpt and cds.cod_centro_servicio = a.cod_cds and a.id_profile = "+profileCPT+")";

		xCdsFilter = "";
}else{selectedVal = "";}

		if(!examen.equals("") || !xCds.equals("") || (!profileCPT.trim().equals("") && !profileCPT.equals("0"))){
		if (fp.equalsIgnoreCase("imagenologia")){

			sql = "select z.*, rownum as secOrden from (select a.codigo, coalesce(a.observacion,a.descripcion)||' ('||a.codigo||')' as descripcion, 0 as producto, b.cod_centro_servicio as centroServicio, b.cod_centro_servicio cdsRecibido, a.cod_cds as procedimientoCds, 'H' as prioridad, 'N' as seleccionado, 1 as tipoOrden, c.descripcion centroServicioDesc from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds b, tbl_cds_centro_servicio c where a.codigo=b.cod_procedimiento and b.cod_centro_servicio = c.codigo "+xCdsFilter+appendFilter+xCdsFilterProfile1+" and c.reporta_a in (select codigo from tbl_cds_centro_servicio where interfaz='RIS') and a.precio is not null and a.estado='A' union select a.cpt, a.descripcion||' ('||a.cpt||')', a.codigo, a.cod_centro_servicio, c.codigo cod_cds, a.cod_centro_servicio as procedimientoCds, 'H' as prioridad, 'N' as seleccionado, 1 as tipoOrden, c.descripcion cds_desc from tbl_cds_producto_x_cds a, tbl_cds_centro_servicio c where cod_centro_servicio=c.codigo"+xCdsFilter+((examen != null && !examen.trim().equals(""))?" and upper(a.descripcion||' ('||a.cpt||')') like '"+examen.toUpperCase()+"%'":"")+
			" and a.cpt is not null and not exists (SELECT 1 FROM tbl_CDS_PROCEDIMIENTO A, tbl_CDS_PROCEDIMIENTO_X_CDS B, tbl_cds_centro_servicio c WHERE  A.CODIGO = B.COD_PROCEDIMIENTO  and b.cod_centro_servicio = c.codigo and c.reporta_a in (select codigo from tbl_cds_centro_servicio where interfaz='RIS')"+xCdsFilter+appendFilter+" AND B.USADO_POR_CU = 'N' and a.precio is not null  and a.codigo = cpt and a.estado = 'A')"+xCdsFilterProfile2+" order by 2) z order by z.centroServicio asc";

			System.out.println(":::::::::::::::::::::::::::::::::::THEBRAIN IMAGENOLOGIA");
		} else if (fp.equalsIgnoreCase("laboratorio")){
			if (!examen.trim().equals("")) { xCdsFilter = ""; profileCPT = "0"; }
			sql = "select decode(cod_centro_sol_lis,null,' ',cod_centro_sol_lis) as cod_centro_sol_lab from tbl_cds_centro_servicio where  codigo="+cds;

			al = SQLMgr.getDataList(sql);
			cdo = new CommonDataObject();
			if (al.size() == 0) throw new Exception("Código de Centro para hacer la Solicitud de Laboratorio no se encuentra. Verificar los parámetros..., VERIFIQUE!");
			else if (al.size() == 1){
				cdo = (CommonDataObject) al.get(0);
				if (cdo.getColValue("cod_centro_sol_lab").trim().equals("")) throw new Exception("Código de Centro para hacer la Solicitud de Laboratorio no se encuentra. Verificar los parámetros..., VERIFIQUE!");
			} else throw new Exception("Código de Centro para hacer la solicitud de Laboratorio está duplicado. Verificar los parámetros..., VERIFIQUE!");

			sql = "select a.codigo, coalesce(a.observacion,a.descripcion) /*nvl(b.descripcion_corto,' ')*/ as descripcion, 'N' as seleccionado, /* se agrega el centro del proc. Benito 04/02/2012 para que solicitud salga en el centro que procesa el cpt"+cdo.getColValue("cod_centro_sol_lab")+"*/ b.cod_centro_servicio as centroServicio, b.cod_centro_servicio cdsRecibido, 1 as tipoOrden, rownum as secOrden, b.cod_centro_servicio cod_cds, c.descripcion centroServicioDesc from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds b, tbl_cds_centro_servicio c where a.codigo=b.cod_procedimiento and b.cod_centro_servicio = c.codigo "+xCdsFilter+appendFilter+xCdsFilterProfile1+" and c.reporta_a in (select codigo from tbl_cds_centro_servicio where interfaz='LIS') /* ya no se utilizará los centros no son los mismos  and b.usado_por_cu='S' */ and a.precio is not null and a.estado = 'A' order by 4,2 asc ";

			selectedVal = "";
		}
		else if (fp.equalsIgnoreCase("BDS")){
		
		
		sbSql = new StringBuffer();
		sbSql.append("select codigo as optValueColumn, descrip_motivo||' - '||codigo as optLabelColumn, activa_observ as optTitleColumn from tbl_sal_motivo_sol_proc where estado_motivo = 'A' "); 
		alM = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);
	
	
			if (!examen.trim().equals("")) { xCdsFilter = ""; profileCPT = "0"; }
			sql = "select decode(cod_centro_sol_lis,null,' ',cod_centro_sol_lis) as cod_centro_sol_lab from tbl_cds_centro_servicio where  codigo="+cds;

			al = SQLMgr.getDataList(sql);
			cdo = new CommonDataObject();
			if (al.size() == 0) throw new Exception("Código de Centro para hacer la Solicitud de Banco de Sangre no se encuentra. Verificar los parámetros..., VERIFIQUE!");
			else if (al.size() == 1){
				cdo = (CommonDataObject) al.get(0);
				if (cdo.getColValue("cod_centro_sol_lab").trim().equals("")) throw new Exception("Código de Centro para hacer la Solicitud de Banco de Sangre no se encuentra. Verificar los parámetros..., VERIFIQUE!");
			} else throw new Exception("Código de Centro para hacer la solicitud de Laboratorio está duplicado. Verificar los parámetros..., VERIFIQUE!");

			sql = "select a.codigo, coalesce(a.observacion,a.descripcion) /*nvl(b.descripcion_corto,' ')*/ as descripcion, 'N' as seleccionado, /* se agrega el centro del proc. Benito 04/02/2012 para que solicitud salga en el centro que procesa el cpt"+cdo.getColValue("cod_centro_sol_lab")+"*/ b.cod_centro_servicio as centroServicio, b.cod_centro_servicio cdsRecibido, 1 as tipoOrden, rownum as secOrden, b.cod_centro_servicio cod_cds, c.descripcion centroServicioDesc,nvl(b.display_order,1000) as display_order , '' as motivos, nvl(b.display_qty,'N') as fieldQty, nvl(b.display_freq,'N') as fieldFreq, nvl(b.display_vol,'N') as fieldVol, nvl(b.display_rsn,'N') as fieldRsn, nvl(b.display_prior,'N') as other1,1 as cantidad ,1 as unidadDosis from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds b, tbl_cds_centro_servicio c where a.codigo=b.cod_procedimiento and b.cod_centro_servicio = c.codigo "+xCdsFilter+appendFilter+xCdsFilterProfile1+" and c.reporta_a in (select codigo from tbl_cds_centro_servicio where interfaz='BDS')  and a.precio is not null and a.estado = 'A' order by 4,2 asc ";

			selectedVal = "";
		}
		System.out.println("SQL = "+sql);
		al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleOrdenMed.class);
		HashDet.clear();
		for (int i=1; i<=al.size(); i++)
		{
			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;

			DetalleOrdenMed dom = (DetalleOrdenMed) al.get(i-1);

			dom.setKey(key);
			dom.setCheck("N");

			HashDet.put(key,dom);
		}
		}

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
function doAction(){parent.doAction();chkProfileCPT();}
function doSubmit()
{
	document.form0.baction.value = parent.document.form001.baction.value;
	document.form0.dob.value = parent.document.form001.dob.value;
	document.form0.codPac.value = parent.document.form001.codPac.value;
	document.form0.formaSolicitud.value = parent.document.form001.formaSolicitud.value;
	document.form0.extraccion.value = parent.document.form001.extraccion.value;
	document.form0.xCds.value = parent.document.form001.xCds.value;
	document.form0.codigoMedico.value = parent.document.form001.codigoMedico.value;
	document.form0.nombreMedico.value = parent.document.form001.nombreMedico.value;
	document.form0.admMedico.value = parent.document.form001.admMedico.value;

	if (!form0Validation())
	{
		parent.form001BlockButtons(false);
		form0BlockButtons(false);
		return false;
	}
	

	document.form0.submit();
}



function validateProc(k)
{

	var dob=parent.parent.document.paciente.fechaNacimiento.value; // fecha nacimiento
	var codPac=parent.parent.document.paciente.codigoPaciente.value; //pacId
	var codigo=eval('document.form0.cod_procedimiento'+k).value; //codigo del checkbox
	var descrip =eval('document.form0.descripcion'+k).value; //
	var centro_servicio=eval('document.form0.centro_servicio'+k).value; // 4
	var prioridad='';
	var fechaOrden=eval('document.form0.fechaOrden'+k).value;
	var sql =''; 
	var cantidad='';
	var frecuencia='';
	var motivo='';
	var comentario='';
	var vol_pediatrico='';
	var unidadDosis='';
	var tipaje='';
	var causa='';
		var descripcion =  replaceAll(descrip,"\'","\'\'");
	if(eval('document.form0.prioridad'+k))
	{
		if(eval('document.form0.prioridad'+k)[0].checked)prioridad=eval('document.form0.prioridad'+k)[0].value;
		else if(eval('document.form0.prioridad'+k)[1].checked)prioridad=eval('document.form0.prioridad'+k)[1].value;
		else if(eval('document.form0.prioridad'+k)[2].checked)prioridad=eval('document.form0.prioridad'+k)[2].value;
		else if(eval('document.form0.prioridad'+k)[3].checked){prioridad=eval('document.form0.prioridad'+k)[3].value; sql =', fecha_orden=to_date(\''+fechaOrden+'\',\'dd/mm/yyyy\')';}
	}
	if(eval('document.form0.causa'+k))
	{
		if(eval('document.form0.causa'+k)[0].checked)causa=eval('document.form0.causa'+k)[0].value;
		else if(eval('document.form0.causa'+k)[1].checked)causa=eval('document.form0.causa'+k)[1].value;
		else if(eval('document.form0.causa'+k)[2].checked)causa=eval('document.form0.causa'+k)[2].value;
		else if(eval('document.form0.causa'+k)[3].checked){causa=eval('document.form0.causa'+k)[3].value;}
		sql+=', causa = \''+causa+'\'';
	}
	if(eval('document.form0.cantidad'+k)){cantidad=eval('document.form0.cantidad'+k).value;sql+=', cantidad = \''+cantidad+'\'';}
	if(eval('document.form0.frecuencia'+k)){frecuencia=eval('document.form0.frecuencia'+k).value;sql+=' , frecuencia = \''+frecuencia+'\'';}
	if(eval('document.form0.motivo'+k)){motivo=eval('document.form0.motivo'+k).value;sql+=', motivo = \''+motivo+'\'';}
	if(eval('document.form0.comentario'+k)){comentario=eval('document.form0.comentario'+k).value;sql+=', comentario = \''+comentario+'\'';}
	if(eval('document.form0.volumen_ped'+k)){vol_pediatrico=eval('document.form0.volumen_ped'+k).value;sql+=', vol_pediatrico = \''+vol_pediatrico+'\'';}	
	if(eval('document.form0.unidad_dosis'+k)){unidadDosis=eval('document.form0.unidad_dosis'+k).value;}
	if(parseInt(unidadDosis)>parseInt(cantidad)){eval('document.form0.unidad_dosis'+k).value =''; alert('La Unidad Dosis no puede ser mayor a la Cantidad Total!');if(eval('document.form0.valor'+k))eval('document.form0.valor'+k).checked=false; unidadDosis=cantidad;}
	else { sql+=', unidad_dosis = \''+unidadDosis+'\'';}	
		
	if(eval('document.form0.tipaje'+k)){tipaje=eval('document.form0.tipaje'+k).value;sql+=', tipaje = \''+tipaje+'\'';}
		
	var observ=(eval('document.form0.observacion'+k))?eval('document.form0.observacion'+k).value:'';
	var observacion =  replaceAll(observ,"\'","\'\'");
	var checked=(eval('document.form0.valor'+k))?eval('document.form0.valor'+k).checked:false;
	
	if(eval('document.form0.cantidad'+k))if(eval('document.form0.fieldQty'+k).value=='R')eval('document.form0.cantidad'+k).className='Text10 FormDataObjectRequired';
		if(eval('document.form0.frecuencia'+k))if(eval('document.form0.fieldFreq'+k).value=='R')eval('document.form0.frecuencia'+k).className='Text10 FormDataObjectRequired';
		if(eval('document.form0.volumen_ped'+k))if(eval('document.form0.fieldVol'+k).value=='R')eval('document.form0.volumen_ped'+k).className='Text10 FormDataObjectRequired';
		var ckComment=false;
		if(eval('document.form0.motivo'+k)){ckComment=(getSelectedOptionTitle(eval('document.form0.motivo'+k),'N')=='S');if(eval('document.form0.fieldRsn'+k).value=='R')eval('document.form0.motivo'+k).className='Text10 FormDataObjectRequired';}
		if(ckComment)if(eval('document.form0.comentario'+k))eval('document.form0.comentario'+k).className='FormDataObjectRequired';
	
	if(checked||observacion.trim()!='')
	{
		if(parent.document.form001.profile)if(parent.document.form001.profile.value==''){
			var allowChange=true;
			//if(parent.document.form001.xCds.value!=''&&parent.document.form001.xCds.value!=eval('document.form0.cod_cds'+k).value)allowChange=confirm('Desea cambiar el Centro que Solicita por el Centro del Procedimiento?');
			if(allowChange)parent.document.form001.xCds.value = eval('document.form0.cod_cds'+k).value;
		}
		
		if(hasDBData('<%=request.getContextPath()%>','tbl_sal_ficha_procedimiento','pac_id=<%=pacId%> and admision=<%=secuenciaCorte%> and codigo=\''+codigo+'\''))
		{
			if(!executeDB('<%=request.getContextPath()%>','update tbl_sal_ficha_procedimiento set seleccionado=\'S\', prioridad=\''+prioridad+'\', observacion=\''+observacion+'\''+sql+' where pac_id=<%=pacId%> and admision=<%=secuenciaCorte%> and codigo=\''+codigo+'\'','tbl_sal_ficha_procedimiento'))
			{
				if(eval('document.form0.valor'+k))eval('document.form0.valor'+k).checked=false;
				else if(eval('document.form0.observacion'+k))eval('document.form0.observacion'+k).value='';
				alert('Hubo un error al tratar de actualizar en temporal!');
			}
		}
		else
		{
			if(prioridad=='O'||prioridad=='W')sql='to_date(\''+fechaOrden+'\',\'dd/mm/yyyy\')';
			else if(prioridad=='M')sql='to_date(to_char(sysdate,\'dd/mm/yyyy\'),\'dd/mm/yyyy\')+1';
			else sql='to_date(to_char(sysdate,\'dd/mm/yyyy\'),\'dd/mm/yyyy\')';
			//sal310150.PU_INS_REG_SOLICITADO
			if(!executeDB('<%=request.getContextPath()%>','insert into tbl_sal_ficha_procedimiento (codigo, prioridad, observacion, usuario, seleccionado, centro_servicio, descripcion, precio, tipo_orden, fecha_nacimiento, codigo_paciente, admision, usuario_creacion, fecha_creacion,fecha_orden, pac_id,interfaz,frecuencia, cantidad, motivo, comentario, vol_pediatrico,causa,unidad_dosis) values (\''+codigo+'\', \''+prioridad+'\', \''+observacion+'\', \'<%=(String) session.getAttribute("_userName")%>\', \'S\', '+centro_servicio+', \''+descripcion+'\', null, 1, to_date(\''+dob+'\',\'dd/mm/yyyy\'), '+codPac+', <%=secuenciaCorte%>, \'<%=(String) session.getAttribute("_userName")%>\', sysdate, '+sql+', <%=pacId%>,\'<%=interfaz%>\', \''+frecuencia+'\', \''+cantidad+'\', \''+motivo+'\', \''+comentario+'\', \''+vol_pediatrico+'\', \''+causa+'\', \''+unidadDosis+'\')','tbl_sal_ficha_procedimiento'))
			{
				if(eval('document.form0.valor'+k))eval('document.form0.valor'+k).checked=false;
				else if(eval('document.form0.observacion'+k))eval('document.form0.observacion'+k).value='';
				alert('Hubo un error al tratar de guardar en temporal!');
			}
		}
	}
	else
	{
		//sal310150.PU_DEL_REG_SOLICITADO
		if(!executeDB('<%=request.getContextPath()%>','delete from tbl_sal_ficha_procedimiento where pac_id=<%=pacId%> and admision=<%=secuenciaCorte%> and codigo=\''+codigo+'\'','tbl_sal_ficha_procedimiento'))
		{
			if(eval('document.form0.valor'+k))eval('document.form0.valor'+k).checked=true;
			else if(eval('document.form0.observacion'+k))eval('document.form0.observacion'+k).value='';
			alert('Hubo un error al tratar de remover en temporal!');
		}
		if(eval('document.form0.cantidad'+k))if(eval('document.form0.fieldQty'+k).value=='R')eval('document.form0.cantidad'+k).className='Text10 FormDataObjectEnabled';
		if(eval('document.form0.frecuencia'+k))if(eval('document.form0.fieldFreq'+k).value=='R')eval('document.form0.frecuencia'+k).className='Text10 FormDataObjectEnabled';
		if(eval('document.form0.volumen_ped'+k))if(eval('document.form0.fieldVol'+k).value=='R')eval('document.form0.volumen_ped'+k).className='Text10 FormDataObjectEnabled';
		var ckComment=false;
		if(eval('document.form0.motivo'+k)){ckComment=(getSelectedOptionTitle(eval('document.form0.motivo'+k),'N')=='S');if(eval('document.form0.fieldRsn'+k).value=='R')eval('document.form0.motivo'+k).className='Text10 FormDataObjectEnabled';}
		if(ckComment)if(eval('document.form0.comentario'+k))eval('document.form0.comentario'+k).className='FormDataObjectEnabled';
	}

}

function validatePrioridad(){
	var checked =false;
	for(i=0;i<=<%=HashDet.size()%>;i++)
	{
		checked=(eval('document.form0.valor'+i))?eval('document.form0.valor'+i).checked:false;
		if(checked)
		{
			if(!((eval('document.form0.prioridad'+i)[0].checked)||(eval('document.form0.prioridad'+i)[1].checked)||(eval('document.form0.prioridad'+i)[2].checked)||(eval('document.form0.prioridad'+i)[3].checked)))
			{
			 	return false;
			 }
		}
	}
	return true;
}

function existsPendingProc()
{
	if(hasDBData('<%=request.getContextPath()%>','tbl_sal_ficha_procedimiento','pac_id=<%=pacId%> and admision=<%=secuenciaCorte%> and centro_servicio in (select codigo from tbl_cds_centro_servicio where estado= \'A\' and interfaz= \'<%=interfaz%>\') '))return true;
	else return false;
}

function prioridadChanged(k)
{
	if(eval('document.form0.observacion'+k).value.trim()!='')
	{
		eval('document.form0.observacion'+k).focus();
		eval('document.form0.observacion'+k).blur();
	}


	if(eval('document.form0.prioridad'+k)[3].checked && (eval('document.form0.prioridad'+k)[3].value=='O' ||eval('document.form0.prioridad'+k)[3].value=='W'))
	{
		eval('document.form0.fechaOrden'+k).readOnly=false;
		eval('document.form0.fechaOrden'+k).className='form-control FormDataObjectEnabled';
		if(eval('document.form0.resetfechaOrden'+k))eval('document.form0.resetfechaOrden'+k).disabled=false;
		alert('Introduzca la Fecha para Generar la Orden');
	}else
	{
		validateProc(k);
		eval('document.form0.fechaOrden'+k).readOnly=true;
		eval('document.form0.fechaOrden'+k).className='form-control FormDataObjectDisabled';
		eval('document.form0.fechaOrden'+k).value='';
		if(eval('document.form0.resetfechaOrden'+k))eval('document.form0.resetfechaOrden'+k).disabled=true;
	}
}
function verifyDuplicatedProc()
{
<%
if (fp.equalsIgnoreCase("imagenologia"))
{
%>
	var cds=document.form0.xCds.value;
<%
}
else if (fp.equalsIgnoreCase("laboratorio")||fp.equalsIgnoreCase("BDS"))
{
%>
	var cds=document.form0.xCds.value;
<%
}
%>
var sqlWhere='';
	if(parent.document.form001.profile){if(parent.document.form001.profile.value=='')document.form0.expCliParamCds.value=cds;}
	else document.form0.expCliParamCds.value=cds;

	if(cds ==''){sqlWhere =' and interfaz= \'<%=interfaz%>\''; }else{ sqlWhere =' and z.centro_servicio='+cds;}
	if(hasDBData('<%=request.getContextPath()%>','tbl_sal_ficha_procedimiento z','z.pac_id=<%=pacId%> and z.admision=<%=secuenciaCorte%> '+sqlWhere+' and z.seleccionado=\'S\' and z.codigo in (select procedimiento from tbl_sal_orden_medica a, tbl_sal_detalle_orden_med b where a.pac_id=<%=pacId%> and a.secuencia=<%=secuenciaCorte%> and a.fecha=to_date(to_char(sysdate,\'dd/mm/yyyy\'),\'dd/mm/yyyy\') and b.procedimiento=z.codigo and a.pac_id=b.pac_id and a.secuencia=b.secuencia and a.codigo=b.orden_med and b.estado_orden in (\'A\'))'))
	{
		var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','distinct z.codigo, z.descripcion','tbl_sal_ficha_procedimiento z','z.pac_id=<%=pacId%> and z.admision=<%=secuenciaCorte%> '+sqlWhere+' and z.seleccionado=\'S\' and z.codigo in (select procedimiento from tbl_sal_orden_medica a, tbl_sal_detalle_orden_med b where a.pac_id=<%=pacId%> and a.secuencia=<%=secuenciaCorte%> and a.fecha=to_date(to_char(sysdate,\'dd/mm/yyyy\'),\'dd/mm/yyyy\') and b.procedimiento=z.codigo and a.pac_id=b.pac_id and a.secuencia=b.secuencia and a.codigo=b.orden_med and b.estado_orden in (\'A\'))',''));
		var duplicatedProc=document.form0.duplicatedProc.value;
		var generateDuplicatedProc=document.form0.generateDuplicatedProc.value;
		var counterN=0;
		for(i=0;i<r.length;i++)
		{
			var c=r[i];
			if(duplicatedProc.trim()!='')duplicatedProc+=','+c[0];
			else duplicatedProc+=c[0];
			if(confirm('El procedimiento "'+c[1]+'" ya fue solicitado este día!\n¿Desea generar otra Orden Médica?'))
			{
				if(generateDuplicatedProc.trim()!='')generateDuplicatedProc+=',';
				generateDuplicatedProc+='Y';
			}
			else
			{
				if(generateDuplicatedProc.trim()!='')generateDuplicatedProc+=',';
				generateDuplicatedProc+='N';
				counterN++;
			}
		}
		if(counterN==r.length)return false;
		document.form0.duplicatedProc.value=duplicatedProc;
		document.form0.generateDuplicatedProc.value=generateDuplicatedProc;
	} 
	return true;
}
function observaciones(obj,k){
	<%if(profileCPT.equals("")){%>validateProc(k);<%}%>
	if(getSelectedOptionTitle(obj,'N')=='S'){
		eval('document.form0.comentario'+k).readOnly=false;
		eval('document.form0.comentario'+k).className='FormDataObjectRequired';
		alert('Por favor introduzca las Indicaciones Adicionales!');
	}else{
		eval('document.form0.comentario'+k).readOnly=true;
		eval('document.form0.comentario'+k).className='FormDataObjectDisabled';
	}
}
function loadProfileCPT(){<% if (!profileCPT.trim().equals("") && !profileCPT.equals("0")) { %>for(i=0;i<<%=HashDet.size()%>;i++)validateProc(i);<% } %>return true;}
function chkProfileCPT(){<% if (!profileCPT.trim().equals("") && !profileCPT.equals("0") && (fp.equalsIgnoreCase("laboratorio")||fp.equalsIgnoreCase("BDS"))) { %>for(i=0;i<<%=HashDet.size()%>;i++)eval('document.form0.valor'+i).checked=true;<% } %>return true;}
</script>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">
	<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%> <%=fb.hidden("baction","")%> <%=fb.hidden("mode",mode)%> <%=fb.hidden("seccion",seccion)%> <%=fb.hidden("size",""+HashDet.size())%> <%=fb.hidden("dob","")%> <%=fb.hidden("codPac","")%> <%=fb.hidden("pacId",pacId)%> <%=fb.hidden("noAdmision",noAdmision)%> <%=fb.hidden("fp",fp)%> <%=fb.hidden("cds",cds)%> <%=fb.hidden("formaSolicitud","")%> <%=fb.hidden("extraccion","")%> <%=fb.hidden("xCds",xCds)%> <%=fb.hidden("xCdsDesc","")%> <%=fb.hidden("codigoMedico","")%> <%=fb.hidden("nombreMedico","")%> <%=fb.hidden("duplicatedProc","")%> <%=fb.hidden("generateDuplicatedProc","")%> <%=fb.hidden("expCliParamCds","")%> <%=fb.hidden("examen",examen)%>
	<%=fb.hidden("admMedico","")%>
	<%=fb.hidden("profileCPT",profileCPT)%>
	<%=fb.hidden("selectedVal",selectedVal)%>
	<%=fb.hidden("secuenciaCorte",secuenciaCorte)%>

    <table cellspacing="0" class="table table-small-font table-bordered table-striped">
    <%
if (fp.equalsIgnoreCase("imagenologia"))
{
%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='Solicitar'){if(loadProfileCPT()&&!existsPendingProc()){alert('Para hacer una Solicitud, por lo menos debe haber un Examen con Sospecha!');error++;}}");%>
	<tr class="bg-headtabla">
		<th width="3%">&nbsp;</td>
		<th width="12%"><cellbytelabel id="2">CDS</cellbytelabel></th>
		<th width="45%"><cellbytelabel id="3">Descripci&oacute;n</cellbytelabel></th>
		<th width="10%"><cellbytelabel id="4">Prioridad</cellbytelabel></th>
		<th width="30%"><cellbytelabel id="5">Sospecha Diagn&oacute;stica</cellbytelabel> </th>
	</tr>
	<%
	al = CmnMgr.reverseRecords(HashDet);
	for (int i=0; i<HashDet.size(); i++)
	{
		key = al.get(i).toString();
		DetalleOrdenMed dom = (DetalleOrdenMed) HashDet.get(key);
		String color = "TextRow02";
		if (i % 2 == 0) color = "TextRow01";
%>
						<%=fb.hidden("key"+i,key)%>
						<%=fb.hidden("descripcion"+i,dom.getDescripcion())%>
						<%=fb.hidden("cod_procedimiento"+i,dom.getCodigo())%>
						<%=fb.hidden("centro_servicio"+i,dom.getCentroServicio())%>
						<%=fb.hidden("prior"+i,dom.getPrioridad())%>
						<%=fb.hidden("cod_cds"+i,dom.getCdsRecibido())%>
						<tr>
							<td>&nbsp;</td>
							<td><%=dom.getCentroServicioDesc()%></td>
							<td><%=dom.getDescripcion()%></td>
							<td><%=fb.radio("prioridad"+i,"H",true,false,viewMode,null,null,"onClick=\"prioridadChanged("+i+")\"")%><cellbytelabel id="6">Hoy</cellbytelabel><br>
								<%=fb.radio("prioridad"+i,"M",false,false,viewMode,null,null,"onClick=\"prioridadChanged("+i+")\"")%> <cellbytelabel id="7">Ma&ntilde;ana</cellbytelabel><br>
								<%=fb.radio("prioridad"+i,"U",false,false,viewMode,null,null,"onClick=\"prioridadChanged("+i+")\"")%> <cellbytelabel id="8">Urgente</cellbytelabel><br>
								<%=fb.radio("prioridad"+i,"O",false,false,viewMode,null,null,"onClick=\"prioridadChanged("+i+")\"")%> <cellbytelabel id="9">Otros</cellbytelabel>
							</td>
							<td class="controls form-inline"><%=fb.textarea("observacion"+i,selectedVal,false,false,viewMode,40,2,2000,"form-control input-sm","width='100%'","onBlur=\"javascript:validateProc("+i+")\"","",false,null,"obser"+dom.getCodigo())%><br>
								<cellbytelabel id="10">Fecha</cellbytelabel>
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="clearOption" value="true"/>
									<jsp:param name="nameOfTBox1" value="<%="fechaOrden"+i%>"/>
									<jsp:param name="valueOfTBox1" value="<%=dom.getFechaOrden()%>"/>
									<jsp:param name="jsEvent" value="<%="validateProc("+i+")"%>"/>
									<jsp:param name="readonly" value="<%=(viewMode||mode.trim().equals("edit"))?"y":"n"%>"/>
								</jsp:include>
							</td>
						</tr>
						<%
	}
	%>
<% } else if (fp.equalsIgnoreCase("laboratorio")) { %>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='Solicitar'){if(loadProfileCPT()&&!existsPendingProc()){alert('Para hacer una Solicitud, por lo menos debe haber un Procedimiento Pendiente!');error++;}}");%>
	<tr class="bg-headtabla">
		<th width="3%">&nbsp;</th>
		<th width="12%"><cellbytelabel id="4">CDS</cellbytelabel></th>
		<th width="45%"><cellbytelabel id="3">Descripci&oacute;n</cellbytelabel></th>
		<th width="10%"><cellbytelabel id="4">Prioridad</cellbytelabel></th>
		<th width="30%">Observaci&oacute;n</th>
	</tr>
	<%
	int lc = 0;//line counter
	int ic = 0;//item counter
	al = CmnMgr.reverseRecords(HashDet);
	for (int i=0; i<HashDet.size(); i++)
	{
		key = al.get(i).toString();
		DetalleOrdenMed dom = (DetalleOrdenMed) HashDet.get(key);
		String color = "TextRow02";
		if (i % 2 == 0) color = "TextRow01";

%>
						<%=fb.hidden("key"+i,key)%>
						<%=fb.hidden("descripcion"+i,dom.getDescripcion())%>
						<%=fb.hidden("cod_procedimiento"+i,dom.getCodigo())%>
						<%=fb.hidden("centro_servicio"+i,dom.getCentroServicio())%>
						<%=fb.hidden("cod_cds"+i,dom.getCdsRecibido())%>
						<tr>
							<td><%=fb.checkbox("valor"+i,dom.getCodigo(),(dom.getCheck().equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:validateProc("+i+")\"",null,null,"proc"+dom.getCodigo())%></td>
							<td><%=dom.getCentroServicioDesc()%></td>
							<td><%=dom.getDescripcion()%></td>
							<td><%=fb.radio("prioridad"+i,"H",true,false,viewMode,null,null,"onClick=\"javascript:prioridadChanged("+i+")\"")%> <cellbytelabel id="6">Hoy</cellbytelabel><br>
								<%=fb.radio("prioridad"+i,"M",false,false,viewMode,null,null,"onClick=\"javascript:prioridadChanged("+i+")\"")%> <cellbytelabel id="7">Ma&ntilde;ana</cellbytelabel><br>
								<%=fb.radio("prioridad"+i,"U",false,false,viewMode,null,null,"onClick=\"javascript:prioridadChanged("+i+")\"")%> <cellbytelabel id="8">Urgente</cellbytelabel><br>
								<%=fb.radio("prioridad"+i,"O",false,false,viewMode,null,null,"onClick=\"javascript:prioridadChanged("+i+")\"")%> <cellbytelabel id="9">Otros</cellbytelabel>
							</td>
							<td class="controls form-inline">
								<%=fb.textarea("observacion"+i,"",false,false,viewMode,40,2,2000,"form-control input-sm","width='100%'","onBlur=\"javascript:validateProc("+i+")\"",null,false,null,"obser"+dom.getCodigo())%><br>
								<cellbytelabel id="10">Fecha</cellbytelabel>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1"/>
								<jsp:param name="clearOption" value="true"/>
								<jsp:param name="nameOfTBox1" value="<%="fechaOrden"+i%>"/>
								<jsp:param name="valueOfTBox1" value="<%=dom.getFechaOrden()%>"/>
								<jsp:param name="jsEvent" value="<%="validateProc("+i+")"%>"/>
								<jsp:param name="readonly" value="<%=(viewMode||!mode.trim().equals(""))?"y":"n"%>"/>
								</jsp:include>
							</td>
						</tr>
		<% } %>
<% } else if (fp.equalsIgnoreCase("BDS")) { %>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='Solicitar'){if(loadProfileCPT()&&!existsPendingProc()){alert('Para hacer una Solicitud, por lo menos debe haber un Procedimiento Pendiente!');error++;}}");%>
	<tr class="bg-headtabla">
		<th width="3%">&nbsp;</th>
		<th width="12%"><cellbytelabel>CDS</cellbytelabel></th>
		<th width="28%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></th>
		<th width="5%"><cellbytelabel>Tipaje</cellbytelabel></th>
		<th width="9%"><cellbytelabel>Prioridad</cellbytelabel></th>
		<th width="18%"><cellbytelabel>Causa</cellbytelabel></th>
		<th width="25%">Observaci&oacute;n</th>
	</tr>
	<%
	int lc = 0;//line counter
	int ic = 0;//item counter
	al = CmnMgr.reverseRecords(HashDet);
	for (int i=0; i<HashDet.size(); i++)
	{
		key = al.get(i).toString();
		DetalleOrdenMed dom = (DetalleOrdenMed) HashDet.get(key);
		String color = "TextRow02";
		if (i % 2 == 0) color = "TextRow01";

%>
						<%=fb.hidden("key"+i,key)%>
						<%=fb.hidden("descripcion"+i,dom.getDescripcion())%>
						<%=fb.hidden("cod_procedimiento"+i,dom.getCodigo())%>
						<%=fb.hidden("centro_servicio"+i,dom.getCentroServicio())%>
						<%=fb.hidden("cod_cds"+i,dom.getCdsRecibido())%>						
						<%=fb.hidden("fieldQty"+i,dom.getFieldQty())%>
						<%=fb.hidden("fieldFreq"+i,dom.getFieldFreq())%>
						<%=fb.hidden("fieldVol"+i,dom.getFieldVol())%>
						<%=fb.hidden("fieldRsn"+i,dom.getFieldRsn())%>
		
						<tr>
							<td><%=fb.checkbox("valor"+i,dom.getCodigo(),(dom.getCheck().equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:validateProc("+i+")\"",null,null,"proc"+dom.getCodigo())%></td>
							<td><%=dom.getCentroServicioDesc()%></td>
							<td><%=dom.getDescripcion()%></td>
							<td><%=fb.textBox("tipaje"+i,"",false,false,viewMode,5,"form-control input-sm","","")%></td> 
							
							 
							 
			<% if ((dom.getOther1() != null && dom.getOther1().trim().equalsIgnoreCase("S")) ) { %>
			<td>
			<%}else{%>
			<td colspan="2">
			<%}%>
			<label class="TextRowOver10"> 
				<%=fb.radio("prioridad"+i,"H",true,false,viewMode,null,null,"onClick=\"javascript:prioridadChanged("+i+")\"")%> <cellbytelabel id="6">Hoy</cellbytelabel><br>
								<%=fb.radio("prioridad"+i,"M",false,false,viewMode,null,null,"onClick=\"javascript:prioridadChanged("+i+")\"")%> <cellbytelabel id="7">Ma&ntilde;ana</cellbytelabel><br>
								<%=fb.radio("prioridad"+i,"U",false,false,viewMode,null,null,"onClick=\"javascript:prioridadChanged("+i+")\"")%> <cellbytelabel id="8">Urgente</cellbytelabel><br>
								<%=fb.radio("prioridad"+i,"O",false,false,viewMode,null,null,"onClick=\"javascript:prioridadChanged("+i+")\"")%> <cellbytelabel id="9">Otros</cellbytelabel><br>
								<%=fb.radio("prioridad"+i,"P",false,false,viewMode,null,null,"onClick=\"javascript:prioridadChanged("+i+")\"")%> <cellbytelabel id="8">PRN</cellbytelabel> 
				</label>   
			</td> 
			<% if ((dom.getOther1() != null && dom.getOther1().trim().equalsIgnoreCase("S")) ) { %>
		   <td>		   
				<%=fb.radio("causa"+i,"X",false,false,viewMode,null,null,"onBlur=\"javascript:validateProc("+i+")\"")%><cellbytelabel id="6">Transfundir Urgente(1HR - 1:30MIN)</cellbytelabel><br>
				<%=fb.radio("causa"+i,"Y",false,false,viewMode,null,null,"onBlur=\"javascript:validateProc("+i+")\"")%><cellbytelabel id="7">Transfundir Hoy(2-3 HR)</cellbytelabel><br>	
				<%=fb.radio("causa"+i,"W",false,false,viewMode,null,null,"onBlur=\"javascript:validateProc("+i+")\"")%><cellbytelabel id="8">Procedimiento Programado</cellbytelabel>	<br>			
				<%=fb.radio("causa"+i,"Z",false,false,viewMode,null,null,"onBlur=\"javascript:validateProc("+i+")\"")%><cellbytelabel id="9">Cruzar/Reservar PRN </cellbytelabel><br>
				<%=fb.radio("causa"+i,"R",false,false,viewMode,null,null,"onBlur=\"javascript:validateProc("+i+")\"")%><cellbytelabel id="9">Reservar</cellbytelabel>
			</td>		
					
		<%}%>    
							<td class="controls form-inline">
								<%=fb.textarea("observacion"+i,"",false,false,viewMode,40,2,2000,"form-control input-sm","width='100%'","onBlur=\"javascript:validateProc("+i+")\"",null,false,null,"obser"+dom.getCodigo())%><br>
								<cellbytelabel id="10">Fecha</cellbytelabel>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1"/>
								<jsp:param name="clearOption" value="true"/>
								<jsp:param name="nameOfTBox1" value="<%="fechaOrden"+i%>"/>
								<jsp:param name="valueOfTBox1" value="<%=dom.getFechaOrden()%>"/>
								<jsp:param name="jsEvent" value="<%="validateProc("+i+")"%>"/>
								<jsp:param name="readonly" value="<%=(viewMode||!mode.trim().equals(""))?"y":"n"%>"/>
								</jsp:include>
							</td>
							
							
						</tr>
						<% if ((dom.getFieldQty() != null && !dom.getFieldQty().equalsIgnoreCase("N")) || (dom.getFieldFreq() != null && !dom.getFieldFreq().equalsIgnoreCase("N")) || (dom.getFieldVol() != null && !dom.getFieldVol().equalsIgnoreCase("N")) || (dom.getFieldRsn() != null && !dom.getFieldRsn().equalsIgnoreCase("N"))) { %>
		<tr class="<%=color%>">
			<td colspan="7">
				<table width="100%" cellpadding="1" cellspacing="0">
					<tr class="<%=color%>">
						<td width="15%"><% if (dom.getFieldQty() != null && !dom.getFieldQty().equalsIgnoreCase("N")) { %>Cantidad Total:<br><%=fb.intBox("cantidad"+i,dom.getCantidad(),false,false,viewMode,5,5,"Text10",null,(profileCPT.equals("")?"onBlur=\"javascript:validateProc("+i+")\"":""))%>
						<br>Unidad Dosis:<%=fb.intBox("unidad_dosis"+i,dom.getUnidadDosis(),false,false,viewMode,5,5,"Text10",null,(profileCPT.equals("")?"onBlur=\"javascript:validateProc("+i+")\"":""))%>
						<% } else { %>&nbsp;<% } %></td>
						<td width="15%"><% if (dom.getFieldFreq() != null && !dom.getFieldFreq().equalsIgnoreCase("N")) { %>Frecuencia:<br><%=fb.textBox("frecuencia"+i,"",false,false,viewMode,25,200,"Text10",null,(profileCPT.equals("")?"onBlur=\"javascript:validateProc("+i+")\"":""))%><% } else { %>&nbsp;<% } %></td>
						<td width="15%"><% if (dom.getFieldVol() != null && !dom.getFieldVol().equalsIgnoreCase("N")) { %>Vol. P&eacute;diatrico Req.:<br><%=fb.textBox("volumen_ped"+i,"",false,false,viewMode,25,200,"Text10",null,(profileCPT.equals("")?"onBlur=\"javascript:validateProc("+i+")\"":""))%><% } else { %>&nbsp;<% } %></td>
						<td width="28%" ><% if (dom.getFieldRsn() != null && !dom.getFieldRsn().equalsIgnoreCase("N")) { %>Motivo:<br><%=fb.select("motivo"+i,alM,"",false,false,viewMode,0,"Text10",null,"onChange=\"javascript:observaciones(this,"+i+")\"","","S")%><% } else { %>&nbsp;<% } %></td>
						<td width="27%"><% if (dom.getFieldRsn() != null && !dom.getFieldRsn().equalsIgnoreCase("N")) { %>Indicaciones adicionales<br><%=fb.textarea("comentario"+i,"",false,false,true,25,2,2000,null,"width='100%'",(profileCPT.equals("")?"onBlur=\"javascript:validateProc("+i+")\"":""))%><% } else { %>&nbsp;<% } %></td>
						
						
					</tr>					 
				</table>
			</td>
		</tr>
		<% } %>
						
		<% } %>
	<%}%>
</table>
	<%fb.appendJsValidation("if(error==0){if(!verifyDuplicatedProc())error++;}");%>
	<%=fb.formEnd(true)%>
</div>
</div>
</body>
</html>
<%
}//GET
else
{
	String baction = request.getParameter("baction");
	size = Integer.parseInt(request.getParameter("size"));
	System.out.println("  ADM  ACTIVA  == "+request.getParameter("secuenciaCorte")+" ADM ROOT =  "+request.getParameter("noAdmision"));
 	OrdenMedica om = new OrdenMedica();

	om.setDuplicatedProc(request.getParameter("duplicatedProc"));
	om.setGenerateDuplicatedProc(request.getParameter("generateDuplicatedProc"));
	om.setCodSala(request.getParameter("cds"));
	om.setCentroServicio(request.getParameter("xCds"));
	om.setExpCliParamCds(request.getParameter("expCliParamCds"));
	//tbl_sal_orden_medica
	//om.setSecuencia(request.getParameter("noAdmision"));
	if(request.getParameter("secuenciaCorte") != null && !request.getParameter("secuenciaCorte").trim().equals(""))
	om.setSecuencia(request.getParameter("secuenciaCorte"));
	else om.setSecuencia(request.getParameter("noAdmision"));
	om.setFecNacimiento(request.getParameter("dob"));
	om.setCodPaciente(request.getParameter("codPac"));
	om.setUsuarioModif((String) session.getAttribute("_userName"));
	om.setUsuarioCreacion((String) session.getAttribute("_userName"));
	om.setCompania((String) session.getAttribute("_companyId"));
	if(request.getParameter("codigoMedico") != null && !request.getParameter("codigoMedico").trim().equals(""))om.setMedico(request.getParameter("codigoMedico"));
	else if(request.getParameter("admMedico") != null && !request.getParameter("admMedico").trim().equals(""))om.setMedico(request.getParameter("admMedico"));
	om.setPacId(request.getParameter("pacId"));
	om.setTelefonica("N");
	//tbl_cds_solicitud
	om.setTipoSolicitud("I");
	om.setOrigen("S");
	om.setEstado("S");
	om.setInterfaz(interfaz);
	om.setProfileCPT(request.getParameter("profileCPT"));
	om.setFormaSolicitud(request.getParameter("formaSolicitud"));
	
		
	if (fp.equalsIgnoreCase("imagenologia"))
	{
		om.setExtraccion("N");

		for (int i=0; i<size; i++)
		{
			if (request.getParameter("observacion"+i) != null && !request.getParameter("observacion"+i).trim().equals(""))
			{
				DetalleOrdenMed dom = new DetalleOrdenMed();

				dom.setTipoOrden("1");
				dom.setCodPaciente(request.getParameter("codPac"));
				dom.setFecNacimiento(request.getParameter("dob"));
				dom.setSecuencia(request.getParameter("noAdmision"));
				//dom.setOrdenMed(request.getParameter("codigo"));
				//dom.setFechaInicio(request.getParameter("fecha"));
				dom.setFechaOrden(request.getParameter("fechaOrden"+i));
				dom.setEjecutado("N");
				dom.setPacId(request.getParameter("pacId"));
				dom.setProcedimiento(request.getParameter("cod_procedimiento"+i));
				dom.setCentroServicio(request.getParameter("centro_servicio"+i));
				dom.setPrioridad(request.getParameter("prioridad"+i));
				dom.setObservacion(request.getParameter("observacion"+i));
				dom.setDescripcion(request.getParameter("descripcion"+i+" - "+request.getParameter("observacion"+i)));
				dom.setExpediente("S");
				dom.setExtraerMuestra("N");
				//dom.setEstudioDev("N");
				dom.setTipoSolicit("P");

				om.addDetalleOrdenMed(dom);
			}
		}
	}
	else if (fp.equalsIgnoreCase("laboratorio")||fp.equalsIgnoreCase("BDS"))
	{
		if (om.getFormaSolicitud() != null && om.getFormaSolicitud().equalsIgnoreCase("T"))	om.setTelefonica("S");
		om.setExtraccion(request.getParameter("extraccion"));

		for (int i=0; i<size; i++)
		{
			if (request.getParameter("valor"+i) != null)
			{

				DetalleOrdenMed dom = new DetalleOrdenMed();

				dom.setTipoOrden("1");
				dom.setCodPaciente(request.getParameter("codPac"));
				dom.setFecNacimiento(request.getParameter("dob"));
				dom.setSecuencia(request.getParameter("noAdmision"));
				//dom.setOrdenMed(request.getParameter("codigo"));
				//dom.setFechaInicio(request.getParameter("fecha"));
				dom.setFechaOrden(request.getParameter("fechaOrden"+i));
				dom.setEjecutado("N");
				dom.setPacId(request.getParameter("pacId"));
				dom.setProcedimiento(request.getParameter("cod_procedimiento"+i));
				dom.setCentroServicio(request.getParameter("centro_servicio"+i));
				//dom.setPrioridad("H");
				dom.setPrioridad(request.getParameter("prioridad"+i));
				dom.setObservacion(request.getParameter("observacion"+i));
				dom.setTipoSolicit("P");
				dom.setDescripcion(request.getParameter("descripcion"+i));
				
				//dom.setCodCds(request.getParameter("CodCds"+i));		
				if (fp.equalsIgnoreCase("BDS"))
				{

					dom.setFrecuencia(request.getParameter("frecuencia"+i));
					dom.setDosis(request.getParameter("cantidad"+i));
					dom.setUnidadDosis(request.getParameter("unidad_dosis"+i));
					
					dom.setTipoOrdenVarios(request.getParameter("motivo"+i));//Se usará este campo para guardar el codigo del motivo de solicitud de Hemocomponentes.			
					if(request.getParameter("comentario"+i) !=null)dom.setObservacionEnf(request.getParameter("comentario"+i));

				}

				om.addDetalleOrdenMed(dom);
			}
		}
	}

	//solicita solo con estudios pendientes
	if (om.getCentroServicio() == null || om.getCentroServicio().trim().equals("")) {
		if (om.getDetalleOrdenMed().size() == 0) {
			OrdenMedica o = (OrdenMedica) sbb.getSingleRowBean(ConMgr.getConnection(), "select centro_servicio as centroServicio from tbl_sal_ficha_procedimiento where pac_id = "+om.getPacId()+" and admision = "+om.getSecuencia()+" and interfaz = '"+interfaz+"' and rownum = 1", OrdenMedica.class);
			if (o != null) {
				om.setCentroServicio(o.getCentroServicio());
				om.setProfileCPT("0");
			}
		}
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ELMgr.add(om);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (ELMgr.getErrCode().equals("1"))
{
%>
	alert('La Orden Médica fue generada satisfactoriamente!');
<%
}
else
{
%>
	/*parent.document.form001.errCode.value='<%=ELMgr.getErrCode()%>';
	parent.document.form001.errMsg.value='<%=IBIZEscapeChars.forHTMLTag(ELMgr.getErrMsg())%>';
	parent.document.form001.submit();*/
	alert('<%=ELMgr.getErrMsg()%>');
<%
}
%>
	parent.window.location.reload(true);
/*
	parent.document.form001.examen.value='';
	if(parent.document.form001.profile)parent.document.form001.profile.value='';
	parent.form001BlockButtons(false);
	parent.showProcedimientos('');
*/
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
