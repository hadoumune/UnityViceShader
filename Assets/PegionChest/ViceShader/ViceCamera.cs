using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace PegionChest{
public class ViceCamera : MonoBehaviour {

	public Material material;

	public Material vicePlaneMaterial;

	Camera cam;
	RenderTexture []rt = new RenderTexture[2];

	int cur = 0;
	int prev = 1;

	// Use this for initialization
	void Start () {
		cam = GetComponent<Camera>();
		Vector2Int quarity = new Vector2Int(512,1024);

		rt[0] = new RenderTexture(quarity.x, quarity.y, 16, RenderTextureFormat.ARGB32);
		rt[0].Create();
		rt[1] = new RenderTexture(quarity.x, quarity.y, 16, RenderTextureFormat.ARGB32);
		rt[1].Create();
		cur = 0;
		prev = 1;
		cam.targetTexture = rt[cur];
		material.SetTexture("_MainTex",rt[prev]);
		vicePlaneMaterial.SetTexture("_MainTex",rt[cur]);
	}

	void Destroy(){
		if ( rt[0] != null ){
			material.SetTexture("_MainTex",null);
			vicePlaneMaterial.SetTexture("_MainTex",null);
			Destroy(rt[0]);
			Destroy(rt[1]);
		}
	}
	
	// Update is called once per frame
	void Update () {
		prev = cur;
		cur = 1-cur;
		cam.targetTexture = rt[cur];
		material.SetTexture("_MainTex",rt[prev]);
		vicePlaneMaterial.SetTexture("_MainTex",rt[cur]);
	}
}
}
