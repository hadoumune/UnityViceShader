using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace PegionChest{
public class ViceCamera : MonoBehaviour {

	public Material material;

	public Material vicePlaneMaterial;

	Camera cam;
	RenderTexture rt;

	// Use this for initialization
	void Start () {
		cam = GetComponent<Camera>();
		Vector2Int quarity = new Vector2Int(512,1024);
		bool useRT = true;

		if ( useRT ){
			rt = new RenderTexture(quarity.x, quarity.y, 16, RenderTextureFormat.ARGB32);
			rt.Create();
			cam.targetTexture = rt;
			material.SetTexture("_MainTex",rt);
			vicePlaneMaterial.SetTexture("_MainTex",rt);
		}
	}

	void Destroy(){
		if ( rt != null ){
			material.SetTexture("_MainTex",null);
			vicePlaneMaterial.SetTexture("_MainTex",null);
			Destroy(rt);
			
		}
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
}
