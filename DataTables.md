DataTables.cfc
===============

A custom JSON render object to convert ColdFusion queries for use with [jQuery DataTables](http://datatables.net/).

Requires ArrayCollection.cfc from this repo.

More example code can be found in the [KungFooGallery ColdBox Applicaiton](https://github.com/iknowkungfoo/KungFooGallery-Simple-ColdBox).

**Simple Example**
```
<cffunction name="art" access="remote" output="false" returntype="String">
	<cfargument name="artist_id" type="numeric"  required="true" />
	<cfset var rs = {} />
	<cfquery name="rs.artwork" datasource="kungfoogallery">
		SELECT
			a.artist_id,
			a.first_name,
			a.last_name,
			b.artwork_id,
			b.title,
			b.img_thumb
		FROM
			ARTISTS a
		INNER JOIN
			ARTWORK b ON b.artist_id = a.artist_id
		<cfif arguments.artist_id GT 0>
			WHERE a.artist_id = <cfqueryparam value="#arguments.artist_id#" cfsqltype="cf_sql_integer" />
		</cfif>
	</cfquery>
	<cfset rs.dt = new DataTables() />
	<cfset rs.dt.setData( rs.artwork ) />
	<cfreturn rs.dt.$renderData() />
</cffunction>

<cfdump var="#art(1)#" />
```

**Output**
```
{
	"iTotalDisplayRecords": 16,
	"iTotalRecords": 16,
	"aaData": [
		[1, 1, "Doug", "8318007055_fa1c3dc930_t.jpg", 88888, "Flower"],
		[1, 2, "Doug", "2808827891_223469fd22_t.jpg", 88888, "Yellow flowers"],
		[1, 3, "Doug", "3086318277_8ee7912476_t.jpg", 88888, "Passion flower"],
		[1, 4, "Doug", "3575863689_f88082c56d_t.jpg", 88888, "Ouch"],
		[1, 5, "Doug", "3428958441_426d432137_t.jpg", 88888, "Yellow"],
		[1, 6, "Doug", "3495905775_b54f784b73_t.jpg", 88888, "Little yellow"],
		[1, 7, "Doug", "3067955110_aab017ef9a_t.jpg", 88888, "Burn Baby Burn"],
		[1, 8, "Doug", "4524800461_30334688bb_t.jpg", 88888, "Earth laughs in Flowers"],
		[1, 9, "Doug", "2913745445_81f10d0b3c_t.jpg", 88888, "Yellow"],
		[1, 10, "Doug", "3545922423_cffb4ecb04_t.jpg", 88888, "Yellow flower"],
		[1, 11, "Doug", "3122503680_6975c6faaf_t.jpg", 88888, "The blues and the greens"],
		[1, 12, "Doug", "3103809905_607649a798_t.jpg", 88888, "Sing the Blues"],
		[1, 13, "Doug", "4530628192_1427fd44d9_t.jpg", 88888, "Canon T2i Flower"],
		[1, 14, "Doug", "3757385629_b58653d59b_t.jpg", 88888, "Macro flower experiment"],
		[1, 15, "Doug", "4522243047_1815f626bd_t.jpg", 88888, "The Daisy"],
		[1, 16, "Doug", "3555700749_ddbb69293e_t.jpg", 88888, "Precious Gift"]
	]
}
```

**Alternate Output**

If we change the code to ourput as a struct.
```
<cfset rs.dt = new DataTables() />
<cfset rs.dt.setData( rs.artwork ) />
<cfset rs.dt.setDataFormat( "struct" ) />
<cfreturn rs.dt.$renderData() />
```

The output returns like so:

```
{
	"iTotalDisplayRecords": 16,
	"iTotalRecords": 16,
	"aaData": [{
		"img_thumb": "8318007055_fa1c3dc930_t.jpg",
		"first_name": "Doug",
		"artwork_id": 1,
		"artist_id": 1,
		"last_name": 88888,
		"title": "Flower"
	}, {
		"img_thumb": "2808827891_223469fd22_t.jpg",
		"first_name": "Doug",
		"artwork_id": 2,
		"artist_id": 1,
		"last_name": 88888,
		"title": "Yellow flowers"
	}, 
	
	// etc.
	
	{
		"img_thumb": "3555700749_ddbb69293e_t.jpg",
		"first_name": "Doug",
		"artwork_id": 16,
		"artist_id": 1,
		"last_name": 88888,
		"title": "Precious Gift"
	}]
}
```
